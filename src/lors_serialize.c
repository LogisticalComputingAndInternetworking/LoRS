#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <lors_api.h>
#include <lors_error.h>
#include <lors_opts.h>
#include <jval.h>
#include <jrb.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

ulong_t g_lm_id = 0;

static void lorsDeserializeMapping(ExnodeMapping *emap, LorsMapping **lmap)
{
    ExnodeFunction  *f;
    ExnodeMetadata  *emd;
    ExnodeValue      val;
    ExnodeType       type;
    LorsMapping     *lm;

    *lmap = NULL;


    /*fprintf(stderr, "deserializing: 0x%x\n", emap);*/
    exnodeGetMappingMetadata(emap, &emd);
    /*fprintf(stderr, "deserializing: returned md 0x%x\n", emd);*/
    if ( emd == NULL ) return;
    lm = (LorsMapping *)calloc(1, sizeof(LorsMapping));
    if ( lm == NULL ) return;

    exnodeGetMetadataValue(emd, "exnode_offset", &val, &type);
    lm->exnode_offset = val.i;
    exnodeGetMetadataValue(emd, "logical_length", &val, &type);
    lm->logical_length = val.i;
    exnodeGetMetadataValue(emd, "alloc_length", &val, &type);
    lm->alloc_length = val.i;
    exnodeGetMetadataValue(emd, "alloc_offset", &val, &type);
    lm->alloc_offset = val.i;

    exnodeGetMetadataValue(emd, "e2e_blocksize", &val, &type);
    lm->e2e_bs = val.i;

    exnodeGetCapabilities(emap, &lm->capset.readCap, &lm->capset.writeCap, &lm->capset.manageCap);
    _lorsGetDepotInfo(&(lm->depot), lm->capset.readCap);
    exnodeCopyMetadata(&(lm->md),emd);
    /*lm->md = emd; */

    if ( g_lors_demo )
    {
        lm->id = _lorsIDFromCap(lm->capset.readCap);
    }
    
    /* Make the mapping function available to the LorsMapping structure. 
     * For Load and Copy operations. */
    exnodeGetFunction(emap, &f);
    exnodeCopyFunction(&lm->function, f);

    *lmap  = lm;
    return;
}

int    safeVersions(double d1, double d2)
{
    if ( (int)(d1*10) - (int)(d2*10) != 0 )
    {
        return 0;
    } else {
        return 1;
    }
}

int    lorsDeserialize (LorsExnode ** exnode,
                        char         *buffer,
                        int           length,
                        char         *schema)
{
    Exnode *e;
    ExnodeEnumeration *en;
    ExnodeMapping     *emap;
    ExnodeMetadata    *emd;
    LorsMapping       *lm;
    ExnodeValue        val;
    ExnodeType         type;
    double              d;
    int                 eret = 0;

    char        *buf;

    eret = exnodeDeserialize(buffer, length, &e);
    if ( eret != EXNODE_SUCCESS )
    {
        return LORS_FAILURE;
    }
    lorsExnodeCreate(exnode);
    (*exnode)->exnode = e;

    exnodeGetMappings(e, &en);
    do 
    {
        exnodeGetNextMapping(en, &emap);
        if ( emap == NULL )
        {
            break;
        }
        lorsDeserializeMapping(emap, &lm);
        lorsAppendMapping(*exnode, lm);

    } while ( emap != NULL );
    exnodeDestroyEnumeration(en);
    exnodeGetExnodeMetadata(e, &emd);
    exnodeGetMetadataValue(emd, "lorsversion", &val, &type);
    lorsGetLibraryVersion(NULL, &d);

    if ( !safeVersions(val.d, d) )
    {
        if ( val.d < d )
        {
            fprintf(stderr, "WARNING: Deseralizing Pre-Version exNode file.\n");
            fprintf(stderr, "This may or may not work.. Continuing...\n");
        }
        if ( val.d > d )
        {
            fprintf(stderr, "WARNING: Deserializing Future-Version exNode file.\n");
            fprintf(stderr, "Operations may fail. Data may be corrupted.\n");
            fprintf(stderr, "You may upgrade at http://loci.cs.utk.edu/lors/\n");
            fprintf(stderr, "Continuing...\n\n");
            sleep(1);
        } 
    }

    if ( exnodeCopyMetadata(&((*exnode)->md),emd) != EXNODE_SUCCESS ){
           return ( LORS_FAILURE);
    };
    /*(*exnode)->md = emd;*/
    /*fprintf(stderr, "0x%x 0x%x\n", (*exnode)->md, emd);*/
    /*fprintf(stderr, "0x%x 0x%x\n", emd->val.v, emd->type);*/

    exnodeDestroyExnode(e);
    (*exnode)->exnode = NULL;

    return LORS_SUCCESS;
}

int    lorsFileDeserialize (LorsExnode ** exnode,
                            char *filename,
                            char *schema)
{
    int             fd;
    int             ret = 0;
    struct stat     mystat;
    char            *buf;

    ret = stat(filename, &mystat);
    if ( ret == -1 )
    {
        fprintf(stderr, "lstat(%s) error:%s\n", filename, strerror(errno));
        return LORS_FAILURE;
    }
#ifdef _MINGW
    if ( !S_ISREG(mystat.st_mode) )
#else
    if ( !S_ISREG(mystat.st_mode) && !S_ISLNK(mystat.st_mode)  )
#endif
    {
        fprintf(stderr, "%s: not a regular file\n", filename);
        return LORS_FAILURE;
    }
#ifdef _MINGW
    fd = open(filename, O_RDONLY|O_BINARY);
#else
    fd = open(filename, O_RDONLY);
#endif
    if ( fd == -1 ) 
    {
        perror("open filename failed");
        return LORS_SYS_FAILED;
    }
    buf = (char *)malloc(sizeof(char) * mystat.st_size);
    if ( buf == NULL ) return LORS_NO_MEMORY;
    ret = read(fd, buf, mystat.st_size);
    if ( ret != mystat.st_size)
    {
        perror("read failed");
        close(fd);
        return LORS_SYS_FAILED;
    }


    ret =  lorsDeserialize(exnode, buf, mystat.st_size, NULL);

    close(fd);
    free(buf);

    return (ret);
    /*fprintf(stderr, "md: 0x%x\n", (*exnode)->md);*/
}

static void lorsSerializeMapping(LorsMapping *lm, ExnodeMapping **emap)
{
    ExnodeMetadata  *emd;
    ExnodeMapping   *map;
    ExnodeValue     val;

    exnodeCreateMapping(&map);
    exnodeGetMappingMetadata(map, &emd);
    val.i = lm->exnode_offset;
    exnodeSetMetadataValue(emd, "exnode_offset", val, INTEGER, TRUE);
    val.i = lm->logical_length;
    exnodeSetMetadataValue(emd, "logical_length", val, INTEGER, TRUE);
    val.i = lm->alloc_length;
    exnodeSetMetadataValue(emd, "alloc_length", val, INTEGER, TRUE);
    val.i = lm->alloc_offset;
    exnodeSetMetadataValue(emd, "alloc_offset", val, INTEGER, TRUE);

    val.i = lm->e2e_bs;

    /*fprintf(stderr, "e2e_bs: %d\n", lm->e2e_bs);*/
    exnodeSetMetadataValue(emd, "e2e_blocksize", val, INTEGER, TRUE);

    exnodeSetCapabilities(map, lm->capset.readCap, 
                               lm->capset.writeCap, 
                               lm->capset.manageCap, TRUE);
    /* copy mapping metadata into the exnode-native md */
    if ( lm->md != NULL )
    {
        lorsMetadataMerge(lm->md, emd);
    }

    /*fprintf(stderr, "Serializing Fxn : 0x%x\n", lm->function);*/
    exnodeSetFunction(map, lm->function, TRUE);
    *emap  = map;
    return;
}

int    lorsSerialize (LorsExnode * exnode,
                      char **buffer,
                      int readonly,
                      int *length)
{
    char *buf;
    int len;
    int     ret = 0;
    JRB     tree, node;
    LorsMapping    *lm;
    ExnodeMapping  *em;
    ExnodeMetadata *ed;
    ExnodeValue     val;
    ExnodeType      type;

    if ( exnode->exnode != NULL ) {
        fprintf(stderr,"serialize: not null\n");
    };

    exnodeCreateExnode(&(exnode->exnode));

    jrb_traverse(node, exnode->mapping_map)
    {
        lm = node->val.v;
        lorsSerializeMapping(lm, &em);

        /*fprintf(stderr, "\tAppending Mapping:0x%x\n", em);*/
        exnodeAppendMapping(exnode->exnode, em);

    }


    exnodeGetExnodeMetadata(exnode->exnode, &ed);

    lorsGetLibraryVersion(NULL, &val.d);
    if ( exnodeGetMetadataValue(ed, "lorsversion", &val, &type) != EXNODE_SUCCESS )
    {
#ifdef _MINGW
        exnodeSetMetadataValue(ed, "lorsversion", val, DOUBLET, TRUE);
#else
        exnodeSetMetadataValue(ed, "lorsversion", val, DOUBLE, TRUE);
#endif
    }

    if ( exnode->md != NULL )
    {
        lorsMetadataMerge(exnode->md, ed);
    }

    ret = exnodeSerialize(exnode->exnode, &buf,  &len);
    if ( ret != EXNODE_SUCCESS )
    {
        return LORS_FAILURE;
    }

    /*fprintf(stderr, "DESTROYING THE EXNODE IN SERIALIZE ______\n");*/
    exnodeDestroyExnode(exnode->exnode);
    exnode->exnode = NULL;
    *buffer = buf;
    *length = len;
    return LORS_SUCCESS;
}


int    lorsFileSerialize (LorsExnode * exnode,
                          char *filename,
                          int readonly,
                          int opts)
{
    int          fd = 0;
    char        *buf = NULL;
    int          len = 0;
    int             ret = 0;
    if ( filename == NULL ) 
    {
        fd = 1;
    } else  
    {
#ifdef _MINGW
        fd = open(filename,  O_WRONLY|O_TRUNC|O_CREAT|O_BINARY, 0666);
#else
        fd = open(filename,  O_WRONLY|O_TRUNC|O_CREAT, 0666);
#endif
        if ( fd == -1 )
        {
            fprintf(stderr, "filename: %s : %lu\n", filename, strlen(filename));
            perror("open filename failed");
            return LORS_SYS_FAILED;
        }
    }
    lorsSerialize(exnode, &buf, 0, &len);
    ret = write(fd, buf, len);
    if ( ret != len )
    {
        perror("write to file failed");
        free(buf);
        if ( fd > 1 ) close(fd);
        return LORS_SYS_FAILED;
    }
    free(buf);
    if ( fd > 1 ) close(fd);
    return LORS_SUCCESS;
}

