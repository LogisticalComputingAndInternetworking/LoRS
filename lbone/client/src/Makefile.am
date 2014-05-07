lib_LTLIBRARIES = libfdr.la liblbone.la
bin_PROGRAMS = client client_mt slm client_mt2 client_mt3 client_res client_res_nws

libfdr_la_SOURCES = jrb.c jval.c dllist.c fields.c
liblbone_la_SOURCES = lbone_client_lib.c lbone_socket.c

IBPINC = @IBPDIR@/include
IBPLIB = @IBPDIR@/lib/libibp.a

AM_CFLAGS = -g -D@OSDEF@
AM_CPPFLAGS = -I../include -I$(IBPINC)


client_SOURCES = client.c
client_LDADD = liblbone.la libfdr.la $(IBPLIB)

client_mt_SOURCES = client_mt.c
client_mt_LDADD = liblbone.la libfdr.la $(IBPLIB)

client_mt2_SOURCES = client_mt2.c
client_mt2_LDADD = liblbone.la libfdr.la $(IBPLIB)

client_mt3_SOURCES = client_mt3.c
client_mt3_LDADD = liblbone.la libfdr.la $(IBPLIB)

client_res_SOURCES = client_res.c
client_res_LDADD = liblbone.la libfdr.la $(IBPLIB)

client_res_nws_SOURCES = client_res_nws.c
client_res_nws_LDADD = liblbone.la libfdr.la $(IBPLIB)

slm_SOURCES = slm.c
slm_LDADD = liblbone.la libfdr.la $(IBPLIB)
