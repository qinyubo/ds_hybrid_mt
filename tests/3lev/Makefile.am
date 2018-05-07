AM_CFLAGS = -DLINUX -g $(DSPACESLIB_CFLAGS)
AM_CPPFLAGS = -I./ -I../../include -I../../dart $(DSPACESLIB_CPPFLAGS)
AM_FCFLAGS = -g $(DSPACESLIB_CPPFLAGS)
AM_LDFLAGS = $(DSPACESLIB_LDFLAGS)

bin_PROGRAMS = dataspaces_server test_lev1_w1 test_lev1_w2 test_lev2 test_lev3

dataspaces_server_SOURCES = common.c dataspaces_server.c
dataspaces_server_LDADD = -L../../src -ldspaces -ldscommon -L../../dart -ldart $(DSPACESLIB_LDADD)

test_lev1_w1_SOURCES = common.c test_put_run.c test_lev1_w1.c
test_lev1_w1_LDADD = -L../../src -ldspaces -ldscommon  -L../../dart -ldart $(DSPACESLIB_LDADD)

test_lev1_w2_SOURCES = common.c test_put_run.c test_lev1_w2.c
test_lev1_w2_LDADD = -L../../src -ldspaces -ldscommon  -L../../dart -ldart $(DSPACESLIB_LDADD)

test_lev2_SOURCES = common.c test_put_run_noinit.c test_get_run_noinit.c test_lev2.c
test_lev2_LDADD = -L../../src -ldspaces -ldscommon  -L../../dart -ldart $(DSPACESLIB_LDADD)

test_lev3_SOURCES = common.c test_put_run_noinit.c test_get_run_noinit.c test_lev3.c
test_lev3_LDADD = -L../../src -ldspaces -ldscommon  -L../../dart -ldart $(DSPACESLIB_LDADD)

noinst_HEADERS = common.h
