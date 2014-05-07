
lib_LTLIBRARIES = libdes.la

includedir=@prefix@/include/@PACKAGE@
include_HEADERS = des.h  des_locl.h  des_ver.h  podd.h  rpc_des.h  sk.h  spr.h

AM_CPPFLAGS = -I.  -D@OSDEF@ -DRAND -O3 -fomit-frame-pointer

libdes_la_SOURCES = cbc_cksm.c cbc_enc.c ecb_enc.c des_enc.c fcrypt_b.c fcrypt.c set_key.c pcbc_enc.c xcbc_enc.c qud_cksm.c cbc3_enc.c cfb64ede.c cfb64enc.c cfb_enc.c ecb3_enc.c enc_read.c enc_writ.c ofb64ede.c ofb64enc.c ofb_enc.c rand_key.c read_pwd.c read2pwd.c rpc_enc.c  str2key.c supp.c des.h  des_locl.h  des_ver.h  podd.h  rpc_des.h  sk.h  spr.h

