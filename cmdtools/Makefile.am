bin_PROGRAMS = lors_upload lors_download lors_ls lors_augment lors_refresh lors_test lors_trim lors_launch lbone_resolution lbone_test lors_route lors_e2etest lors_modify

bindir = @prefix@/bin
libdir = @prefix@/lib

LBNINC = @LORS_LBONE_DIR@/include
LBNLIB = @LORS_LBONE_DIR@/lib/liblbone.la
FDRLIB = @LORS_LBONE_DIR@/lib/libfdr.la

PIPEDIR = $(HOME)/research/xnd_suite/eXnode/pipeline/
PIPEINC = $(PIPEDIR)/local/include
PIPELIB = $(PIPEDIR)/local/lib/libpipeline.la

IBPDIR = @LORS_LBONE_DIR@
IBPINC = $(IBPDIR)/include
IBPLIB = $(IBPDIR)/lib/libibp.la

XNDINC = @LORS_LIBXND_DIR@/include/libexnode/
XNDLIB = @LORS_LIBXND_DIR@/lib/libexnode.la

XML2_INC = @LORS_XML2_DIR@/include/libxml2
XML2_LIB = @LORS_XML2_LIB@ -lxml2

POPT_INC=@LORS_POPT_DIR@/include
POPT_LIB=@LORS_POPT_LIB@ -lpopt

ZLIB_INC=@LORS_ZLIB_DIR@/include
ZLIB_LIB=@LORS_ZLIB_LIB@ -lz

E2EINC = @E2EDIR@
E2ELIB = @E2EDIR@/libend2end.la $(E2EDIR)/md5/libmd5.la $(E2EDIR)/des/libdes.la $(E2EDIR)/aes/libaes.la

LORSLIB = ../src/liblors.la

AM_CPPFLAGS = -I../include -I../lbone/client/include/ -I$(XML2_INC) -I$(XNDINC) -I$(LBNINC) -I$(IBPINC) -I$(E2EINC) -I$(POPT_INC) -I$(ZLIB_INC)  

AM_CFLAGS=  -g -D@OSDEF@ @EXTRA_CFLAGS@
LDADD = $(LORSLIB) $(XNDLIB) $(LBNLIB) $(FDRLIB) $(IBPLIB) $(XML2_LIB) $(POPT_LIB) -lpthread -lxml2 $(E2ELIB) $(ZLIB_LIB) @LIBS@  

lors_upload_SOURCES = lors_upload.c lors_file.c lors_libe2e.c parse_xndrc.c
lors_upload_LDADD = -lpopt $(LDADD)

lors_download_SOURCES = lors_download.c lors_file.c parse_xndrc.c lors_libe2e.c
lors_download_LDADD = -lpopt $(LDADD)

lors_ls_SOURCES = lors_ls.c lors_file.c parse_xndrc.c lors_libe2e.c
lors_ls_LDADD = -lpopt $(LDADD)

lors_augment_SOURCES = lors_augment.c lors_file.c parse_xndrc.c lors_libe2e.c
lors_augment_LDADD = -lpopt $(LDADD)

lors_refresh_SOURCES = lors_refresh.c lors_file.c parse_xndrc.c lors_libe2e.c
lors_refresh_LDADD = -lpopt $(LDADD)

lors_test_SOURCES = lors_test.c lors_file.c lors_libe2e.c
lors_test_LDADD = -lpopt $(LDADD)

lbone_resolution_SOURCES = lbone_resolution.c parse_xndrc.c
lbone_resolution_LDADD = -lpopt $(LDADD)

lbone_test_SOURCES = lbone_test.c parse_xndrc.c
lbone_test_LDADD = -lpopt $(LDADD)

lors_e2etest_SOURCES = lors_e2etest.c parse_xndrc.c lors_file.c lors_libe2e.c
lors_e2etest_LDADD = -lpopt $(LDADD)

lors_route_SOURCES = lors_route.c parse_xndrc.c lors_file.c lors_libe2e.c
lors_route_LDADD = -lpopt $(LDADD)

lors_trim_SOURCES = lors_trim.c lors_file.c lors_libe2e.c parse_xndrc.c
lors_trim_LDADD = -lpopt $(LDADD)

lors_modify_SOURCES = lors_modify.c lors_file.c lors_libe2e.c  parse_xndrc.c
lors_modify_LDADD = -lpopt $(LDADD)

lors_launch_SOURCES = lors_launch.c
lors_launch_LDADD = $(LBNLIB) $(LDADD)
