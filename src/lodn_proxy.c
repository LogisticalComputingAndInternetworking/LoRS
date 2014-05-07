#include "lors_api.h"
#include "lors_internal.h"
#include "xndrc.h"
#include "../lbone/ibp/include/ibp_ClientLib.h"
#include "../lbone/ibp/include/jrb.h"

LorsAllocation lodn_allocation;

//initialize allocation options struct
void proxyAllocateInit(LorsAllocation *allocation) {
	allocation->params = make_jrb();
}

//set proxy allocate options from xndrc file
void setProxyAllocateXndrcOptions(XndRc xndrc, int *enabled , LorsAllocation *allocation) { 
	allocation->type = xndrc.allocation_type;
	//set enabled here because we need it to do proxy option check properly later
	if (allocation->type == LORS_PROXY_ALLOCATION) {
		*enabled = 1;
	    //retreive options from xndrc struct
	    if (xndrc.username) jrb_insert_str(allocation->params,"username",(Jval)strdup(xndrc.username));
	    if (xndrc.password) jrb_insert_str(allocation->params,"password",(Jval)strdup(xndrc.password));
	    if (xndrc.lodn_url) jrb_insert_str(allocation->params,"lodn_url",(Jval)strdup(xndrc.lodn_url));
	} else {
		*enabled = 0;
	}
}

//set proxy allocate options from commandline, returns non-zero if an option was incorrectly formatted
int setProxyAllocateOptions(int enabled, int override, char *options, LorsAllocation *allocation) {
	//if override is set, ignore proxy allocation options and perform normal allocation
	if (override) {
		allocation->type = LORS_NORMAL_ALLOCATION;
		return 0;
	}
	//parses commandline parameters and overwrites values in LorsAllocation struct if necessary
	if (enabled) {
		allocation->type = LORS_PROXY_ALLOCATION;
		//if pointer is null or string is empty, skip this section
		if (options != NULL /*&& *options != '\0'*/) {
			//declare some variables
			char *value,*name,*temp_opts,*temp_opts_org,invalid;
			//set default values
			invalid = 0;
			//get temporary options string
			temp_opts=strdup(options);
			//store original location
			temp_opts_org=temp_opts;
			JRB temp;
			//parse separate name,value pairs
			while((value=strsep(&temp_opts,"&"))!=NULL) {
				//check for an empty 'name=value' pair
				if (*value == '\0') continue;
				//separate name and value
				name=strsep(&value,"=");
				//check for an empty name
				if (*name == '\0') 
				{
					invalid = 1;
					break;
				}
				//check if we reached string end or if value is empty
				if (value == NULL || *value == '\0') 
				{
					invalid = 1;
					break;
				}
				//insert in tree if name and value are valid
				temp=jrb_find_str(allocation->params,name);
				if (temp!=NULL) {
					free(jrb_val(temp).s);
					jrb_delete_node(temp);
				}
				jrb_insert_str(allocation->params,name,new_jval_s(value));
			}
			//free temporary options string
			free(temp_opts_org);
			//if the options were invalid, return 1
			if (invalid) return 1;
		}
	}
	return 0;
}

//checks to make sure all required options are set
//returns zero if there are no errors, non-zero otherwise
int checkProxyAllocateOptions(LorsAllocation allocation) {
	JRB opt1,opt2,opt3;
	opt1 = jrb_find_str(allocation.params,"username");
	opt2 = jrb_find_str(allocation.params,"password");
	opt3 = jrb_find_str(allocation.params,"lodn_url");
	if ( opt1 == NULL || opt2 == NULL || opt3 == NULL) return 1;		
	return 0;
}

//sets proxy allocate option, returns non-zero if an option that previously existed was overwritten
//returns zero otherwise
int setProxyAllocateOption(char *option, char *value, LorsAllocation *allocation) {
	//check if option already exists
	JRB temp = jrb_find_str(allocation->params,option);
	//if it does, delete it and insert it
	if (temp != NULL) {
		jrb_delete_node(temp);
		jrb_insert_str(allocation->params,option,new_jval_s(value));
		return 1;
	//else, just insert it
	} else {
		jrb_insert_str(allocation->params,option,new_jval_s(value));
		return 0;
	}
	
}

//fetches proxy allocate option, returns NULL if named option does not exist
char *getProxyAllocateOption(char *option, LorsAllocation *allocation) {
	JRB temp = jrb_find_str(allocation->params,option);
	if (temp == NULL) return NULL;
	return jrb_val(temp).s;
}

  //returns IBP_set_of_caps upon success, returns NULL upon failure
IBP_set_of_caps lodnProxyAllocate(	IBP_depot ps_depot, 
									IBP_timer ps_timeout, 
									unsigned long int pi_size, 
									IBP_attributes ps_attr) {
	IBP_set_of_caps socaps = malloc(sizeof(struct ibp_set_of_caps));
	return socaps;
}
