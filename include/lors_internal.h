
#ifndef __LORS_INTERNAL_H__
#define __LORS_INTERNAL_H__

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

//int lorsGetDepot(LorsDepotPool *dp, int *id);
//int lorsReleaseDepot(LorsDepotPool *dp, int id, double bw, int nfailures);

//int lorsAddDepot(LorsDepot *d);
int lorsScoreDepot(LorsDepot *d);
int lorsUpdateDepot(LorsDepot *d);

//this struct holds information necessary to authenticate a session
//for LoDN proxy allocation
typedef struct __LorsAllocation {
	unsigned int type;
	JRB params;
} LorsAllocation;

//VALID LorsAllocation TYPES
#define LORS_NORMAL_ALLOCATION 0
#define LORS_PROXY_ALLOCATION 1

extern LorsAllocation lodn_allocation;

#endif
