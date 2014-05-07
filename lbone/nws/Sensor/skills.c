/* $Id: skills.c,v 1.13 2001/02/18 08:52:21 pgeoffra Exp $ */


#define FORKIT

#include <stdlib.h>        /* atoi() */
#include "config.h"
#include "diagnostic.h"    /* FAIL() */
#include "exp_protocol.h"  /* Skill */
#include "host_protocol.h" /* RegisterObject() */
#include "messages.h"      /* message numbers */
#include "strutil.h"       /* GETTOK() */
#include "connect_exp.h"   /* experiment module */
#include "disk.h"          /*     "        "    */
#include "hybridCpu.h"     /*     "        "    */
#include "memory.h"        /*     "        "    */
#include "tcp_bw_exp.h"    /*     "        "    */
#include "skills.h"        /* Prototypes for this module. */


/*
** Messages recognized and/or generated by the skills module:
**
** TCP_BW_REQ(sizes) -- sent to a sensor to request that it handle TCP latency
**   and bandwidth experiments with the enclosed sizes (a TcpBwCtrl -- see
**   tcp_bw_exp.h) from the sender.  
*/
#define TCP_BW_REQ SKILLS_FIRST_MESSAGE


#define DEFAULT_ACTIVE_LENGTH 1500
#define INITIAL_ACTIVE_FREQ 5
#define ONE_K 1024
#define ONE_MEG 1048576
#define RESOURCE_COUNT 7
#define SKILL_COUNT 5

static const char* OPTION_FORMATS =
  "buffer:0_to_1_int\tmessage:0_to_1_int\tnice:0_to_10_int\tpath:1_to_10_string\ttype:0_to_1_string\tsize:0_to_1_int\ttarget:1_to_100_sensor";
static const char* RESOURCE_LABELS[RESOURCE_COUNT] =
  {"CPU Fraction", "Megabits/second", "Milliseconds",
   "CPU Fraction", "Megabytes", "Megabytes", "Milliseconds"};
static const char* RESOURCE_NAMES[RESOURCE_COUNT] =
  {"availableCpu", "bandwidthTcp", "connectTimeTcp",
   "currentCpu", "freeDisk", "freeMemory", "latencyTcp"};
static const char* SKILL_NAMES[SKILL_COUNT] =
  {"cpuMonitor", "diskMonitor", "memoryMonitor", "tcpConnectMonitor",
   "tcpMessageMonitor"};
static const char* SKILL_OPTIONS[SKILL_COUNT] =
  {"nice", "path", "type", "target", "buffer,message,size,target"};
static const int SKILL_RESOURCE_COUNTS[SKILL_COUNT] = {2, 1, 1, 1, 2};
static const MeasuredResources SKILL_RESOURCES[] =
  {availableCpu, currentCpu, freeDisk, freeMemory, connectTimeTcp, bandwidthTcp,
   latencyTcp};


/*
** Module globals.  #defaultSensorPort# caches the default port number for
** sensor hosts.  #lastResults# and #lastResultsLength# holds the list of
** results most recently returned by one of the Use*Skill() functions.
** #cpuOptions# holds the most recent configuration for the CPU monitor.
*/
static unsigned short defaultSensorPort = 0;
static SkillResult *lastResults = NULL;
static int lastResultsLength = 0;
static char *cpuOptions = NULL;


/* Adds a new result with the given fields to lastResults. */
static void
AppendResult(MeasuredResources resource,
             const char *options,
             int succeeded,
             double measurement) {
  SkillResult newResult;
  newResult.resource = resource;
  newResult.options = strdup(options);
  newResult.succeeded = succeeded;
  newResult.measurement = measurement;
  lastResultsLength++;
  lastResults = REALLOC(lastResults, lastResultsLength * sizeof(SkillResult));
  lastResults[lastResultsLength - 1] = newResult;
}


/* Frees the contents of the lastResults module global. */
static void
FreeResults() {
  int i;
  for(i = 0; i < lastResultsLength; i++) {
    free(lastResults[i].options);
  }
  free(lastResults);
  lastResults = NULL;
  lastResultsLength = 0;
}


/* A message listener (see messages.h) for the skills module. */
static void
HandleSkillMessage(Socket *sd,
                   MessageType messageType,
                   size_t dataSize) {

  pid_t pid = 0;
  int result;

#ifdef FORKIT
  if(!CreateLocalChild(&pid, NULL, NULL)) {
    ERROR("ProcessRequest: fork failed.\n");
    return;
  }
  if(pid > 0) {
    /* Parent process. */
    PassSocket(sd, pid);
    return;
  }
#endif

  result = (messageType == TCP_BW_REQ) ? TerminateTcpExp(*sd) : 0;

#ifdef FORKIT
  DROP_SOCKET(sd);
  exit(!result);
#endif

}


const char *
GetOptionValue(const char *options,
               const char *name,
               const char *defaultValue) {

  const char *c;
  size_t nameLen = strlen(name);
  static char *returnValue = NULL;
  const char *value;
  const char *valueEnd;
  size_t valuesLen = 0;

  /* Find the total length of all #name# option values in #options#. */
  for(c = strstr(options, name); c != NULL; c = strstr(c + 1, name)) {
    if((*(c + nameLen) != ':') || ((c != options) && (*(c - 1) != '\t')))
      continue; /* Bogus match. */
    value = c + nameLen + 1;
    valueEnd = strchr(value, '\t');
    valuesLen += (valueEnd == NULL) ? strlen(value) : (valueEnd - value);
    valuesLen++;
  }

  if(valuesLen == 0) {
    return defaultValue;
  }

  /* Merge all #name# option values into a single, comma-delimited list. */
  returnValue = (char *)REALLOC(returnValue, valuesLen);
  memset(returnValue, 0, valuesLen);
  for(c = strstr(options, name); c != NULL; c = strstr(c + 1, name)) {
    if((*(c + nameLen) != ':') || ((c != options) && (*(c - 1) != '\t')))
      continue; /* Bogus match. */
    value = c + nameLen + 1;
    valueEnd = strchr(value, '\t');
    if(*returnValue != '\0') {
      strcat(returnValue, ",");
    }
    strncat(returnValue,
            value,
            (valueEnd == NULL) ? strlen(value) : (valueEnd - value));
  }
  return returnValue;

}


const char *
ResourceLabel(MeasuredResources resource) {
  return RESOURCE_LABELS[resource];
}


const char *
ResourceName(MeasuredResources resource) {
  return RESOURCE_NAMES[resource];
}


int
SkillAvailable(KnownSkills skill,
               const char *options) {
  return (skill == cpuMonitor) ? HybridCpuMonitorAvailable() :
         (skill == memoryMonitor) ? MemoryMonitorAvailable() : 1;
}


const char *
SkillName(KnownSkills skill) {
  return SKILL_NAMES[skill];
}


void
SkillOptions(KnownSkills skill,
             const char *options,
             char *toWhere) {

  const char *c;
  char option[31 + 1];
  const char *value;

  *toWhere = '\0';
  for(c = SKILL_OPTIONS[skill]; GETTOK(option, c, ",", &c); ) {
    if((value = GetOptionValue(options, option, NULL)) != NULL) {
      if(*toWhere != '\0') {
        strcat(toWhere, "\t");
      }
      strcat(toWhere, option);
      strcat(toWhere, ":");
      strcat(toWhere, value);
    }
  }

}


void
SkillResources(KnownSkills skill,
               const char *options,
               const MeasuredResources **resources,
               int *length) {
  const MeasuredResources *firstResource; 
  KnownSkills i;
  firstResource = SKILL_RESOURCES;
  for(i = (KnownSkills)0; i < skill; i++)
    firstResource += SKILL_RESOURCE_COUNTS[i];
  *resources = firstResource;
  *length = SKILL_RESOURCE_COUNTS[skill];
}


int
SkillsInit(void) {

  int i;
  Object toRegister;
  Skill skill;

  SAFESTRCPY(skill.host, EstablishedRegistration());

  for(i = 0; i < SKILL_COUNT; i++) {
    if(SkillAvailable((KnownSkills)i, "")) {
      SkillOptions((KnownSkills)i, OPTION_FORMATS, skill.options);
      SAFESTRCPY(skill.skillName, SKILL_NAMES[i]);
      toRegister = ObjectFromSkill(NameOfSkill(&skill), &skill);
      RegisterObject(toRegister);
      FreeObject(&toRegister);
    }
  }

  defaultSensorPort = DefaultHostPort(SENSOR_HOST);
  RegisterListener(TCP_BW_REQ, "TCP_BW_REQ", &HandleSkillMessage);
  return 1;

}


/*
** NOTE: the checkFrequency parameter to HybridCpuOpenMonitor() is a presently-
** unused leftover from the days when vmstat still figured into the equation.
** Since it's currently unimportant, we just pass a dummy value, rather than
** somehow forcing either the user or the client code to provide us with a
** number.  In fact, the need for {Open,Close}Monitor() calls is an anachronism
** that should be restructured away.  The interface for UseHostSkill() implies
** that multiple uses of the skill with different options do not interfere with
** each other, and the CPU monitor certainly could/should be rewritten to
** support such flexibility.
*/
void
UseSkill(KnownSkills skill,
         const char *options,
         double timeOut,
         const SkillResult **results,
         int *length) {

  double available;
  double bandwidthAndLatency[2];
  const char *c;
  double connect;
  double current;
  double disk;
  char diskPath[63 + 1];
  char experimentOptions[63 + 1];
  double memory;
  char niceValue[7 + 1];
  unsigned short niceValues[20];
  int niceValuesCount;
  TcpBwCtrl sizes;
  IPAddress targetAddress;
  struct host_desc targetHost;
  char targetName[MAX_MACHINE_NAME + 1];
  char memoryType[7 + 1];

  FreeResults();

  if(skill == cpuMonitor) {
    if((cpuOptions == NULL) || (strcmp(cpuOptions, options) != 0)) {
      /* (Re)initialize the CPU monitor using the nice value(s) in #options#. */
      if(cpuOptions != NULL) {
        HybridCpuCloseMonitor();
        free(cpuOptions);
      }
      cpuOptions = strdup(options);
      niceValuesCount = 0;
      for(c = GetOptionValue(options, "nice", "0");
          GETTOK(niceValue, c, ",", &c);
          ) {
        niceValues[niceValuesCount++] = atoi(niceValue);
      }
      HybridCpuOpenMonitor(niceValues,
                           niceValuesCount,
                           10, /* see NOTE above */
                           INITIAL_ACTIVE_FREQ,
                           ADAPT,
                           DEFAULT_ACTIVE_LENGTH,
                           DONT_ADAPT);
    }
    /* Get measurements for each nice value. */
    for(c = GetOptionValue(options, "nice", "0");
        GETTOK(niceValue, c, ",", &c);
        ) {
      vstrncpy(experimentOptions, sizeof(experimentOptions), 2,
               "nice:", niceValue);
      if(HybridCpuGetLoad(atoi(niceValue), &available, &current)) {
        AppendResult(availableCpu, experimentOptions, 1, available);
        AppendResult(currentCpu, experimentOptions, 1, current);
      }
      else {
        AppendResult(availableCpu, experimentOptions, 0, 0.0);
        AppendResult(currentCpu, experimentOptions, 0, 0.0);
      }
    }
  }
  else if(skill == diskMonitor) {
    for(c = GetOptionValue(options, "path", "");
        GETTOK(diskPath, c, ",", &c);
        ) {
      vstrncpy(experimentOptions, sizeof(experimentOptions), 2,
               "path:", diskPath);
      if(DiskGetFree(diskPath, &disk)) {
        AppendResult(freeDisk, experimentOptions, 1, disk / ONE_MEG);
      }
      else {
        AppendResult(freeDisk, experimentOptions, 0, 0.0);
      }
    }
  }
  else if(skill == memoryMonitor) {
    for(c = GetOptionValue(options, "type", "p");
        GETTOK(memoryType, c, ",", &c);
        ) {
      vstrncpy(experimentOptions, sizeof(experimentOptions), 2,
               "type:", memoryType);
      if (strcmp(memoryType,"a") == 0) {
	if(ActiveMemoryGetFree(&memory)) {
	  AppendResult(freeMemory, experimentOptions, 1, memory);
	}
	else {
	  AppendResult(freeMemory, experimentOptions, 0, 0.0);
	}
      }
      else if (strcmp(memoryType, "p") == 0) {
	if(PassiveMemoryGetFree(&memory)) {
	  AppendResult(freeMemory, experimentOptions, 1, memory);
	}
	else {
	  AppendResult(freeMemory, experimentOptions, 0, 0.0);
	}
      }
    }
  }
  else if(skill == tcpConnectMonitor) {
    /* Conduct a connect experiment with each host in the target option. */
    for(c = GetOptionValue(options, "target", "");
        GETTOK(targetName, c, ",", &c);
        ) {
      HostDValue(targetName, defaultSensorPort, &targetHost);
      (void)IPAddressValue(targetHost.host_name, &targetAddress);
      vstrncpy(experimentOptions, sizeof(experimentOptions), 2,
               "target:", HostDImage(&targetHost));
      if(InitiateConnectExp(targetAddress,
                            targetHost.port,
                            timeOut,
                            &connect)) {
        AppendResult(connectTimeTcp, experimentOptions, 1, connect);
      }
      else {
        AppendResult(connectTimeTcp, experimentOptions, 0, 0.0);
      }
    }
  }
  else if(skill == tcpMessageMonitor) {
    sizes.expSize = atoi(GetOptionValue(options, "size", "64")) * ONE_K;
    sizes.bufferSize = atoi(GetOptionValue(options, "buffer", "32")) * ONE_K;
    sizes.msgSize = atoi(GetOptionValue(options, "message", "16")) * ONE_K;
    /* Conduct a message experiment with each host in the target option. */
    for(c = GetOptionValue(options, "target", "");
        GETTOK(targetName, c, ",", &c);
        ) {
      HostDValue(targetName, defaultSensorPort, &targetHost);
      (void)IPAddressValue(targetHost.host_name, &targetAddress);
      sprintf(experimentOptions, "buffer:%d\tmessage:%d\tsize:%d\ttarget:%s",
              sizes.bufferSize / ONE_K,
              sizes.msgSize / ONE_K,
              sizes.expSize / ONE_K,
              HostDImage(&targetHost));
      if(InitiateTcpExp(targetAddress,
                        targetHost.port,
                        TCP_BW_REQ,
                        &sizes,
                        timeOut,
                        &bandwidthAndLatency[0])) {
        AppendResult(bandwidthTcp,experimentOptions,1,bandwidthAndLatency[0]);
        sprintf(experimentOptions, "target:%s", HostDImage(&targetHost));
        AppendResult(latencyTcp, experimentOptions, 1, bandwidthAndLatency[1]);
      }
      else {
        AppendResult(bandwidthTcp, experimentOptions, 0, 0.0);
        sprintf(experimentOptions, "target:%s", HostDImage(&targetHost));
        AppendResult(latencyTcp, experimentOptions, 0, 0.0);
      }
    }
  }
  else {
    ERROR1("UseSkill: invalid skill %d used\n", skill);
  }

  *results = lastResults;
  *length = lastResultsLength;

}