lib_LTLIBRARIES = liblors.la

bindir = @prefix@/bin
libdir = @prefix@/lib

LBNINC = @LORS_LBONE_DIR@/include
LBNLIB = @LORS_LBONE_DIR@/lib/liblbone.la
FDRLIB = @LORS_LBONE_DIR@/lib/libfdr.la

PIPEDIR = $(HOME)/research/xnd_suite/eXnode/pipeline
PIPEINC = $(PIPEDIR)/local/include

IBPDIR = @LORS_LBONE_DIR@
IBPINC = $(IBPDIR)/include
IBPLIB = $(IBPDIR)/lib/IBPClientLib.la

XNDINC = @LORS_LIBXND_DIR@/include/libexnode/
XNDLIB = @LORS_LIBXND_DIR@/src/libexnode.la

XNDXMLINC = @LORS_XML2_DIR@/include/libxml2

POPT_INC=@LORS_POPT_DIR@/include
POPT_LIB="-L@LORS_POPT_DIR@/lib -lpopt"

ZLIB_INC=@LORS_ZLIB_DIR@/include
ZLIB_LIB="-L@LORS_ZLIB_DIR@/lib -lz"

E2EINC = @E2EDIR@
E2ELIB = @E2EDIR@/libend2end.la $(E2EDIR)/md5/libmd5.a $(E2EDIR)/des/libdes.a

AM_CFLAGS = -g -D@OSDEF@  @EXTRA_CFLAGS@
AM_CPPFLAGS = -I../include -I../lbone/client/include/  -I$(XNDXMLINC) -I$(XNDINC) -I$(LBNINC) -I$(IBPINC) -I$(E2EINC) -I$(POPT_INC) -I$(ZLIB_INC) 

ldadd = $(XNDLIB) $(LBNLIB) $(FDRLIB) $(IBPLIB) -L@XNDXMLDIR@/lib @LIBS@ $(ZLIB_LIB) $(POPT_LIB)  
#$(E2ELIB)

liblors_la_SOURCES = lors_exnode.c lors_serialize.c lors_metadata.c lors_depotpool.c lors_util.c lors_job.c lors_set_copy.c lors_set_load.c lors_set_merge.c lors_set_misc.c lors_set_query.c lors_set_refresh.c lors_set_stat.c lors_set_store.c lors_set_trim.c lors_set_alloc.c lors_resolution.c lodn_proxy.c
