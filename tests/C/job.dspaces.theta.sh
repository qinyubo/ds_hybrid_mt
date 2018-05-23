#!/bin/bash
#COBALT -t 00:02:00
#COBALT -n 3
#COBALT -A DataSpaces
#COBALT -q debug-cache-quad
## For Theta, you must provide the GNI cookie via the env var DSPACES_GNI_COOKIE or by 
## compiling with the --with-gni-cookie configure flag

#export DSPACES_GNI_COOKIE=0xe3240000

DIR=.
CONF_DIMS=64

rm -f conf cred dataspaces.conf srv.lck

echo "## Config file for DataSpaces
ndim = 3
dims = $CONF_DIMS, $CONF_DIMS, $CONF_DIMS

max_versions = 1
lock_type = 2
" > dataspaces.conf

aprun -n 1 -p Yubo-test ./dataspaces_server -s 1 -c 2 > server.log 2>&1 < /dev/null &

sleep 2

aprun -n 1 -p Yubo-test ./test_writer DATASPACES 1 3 1 1 1 64 64 64 20 1 > writer.log 2>&1 < /dev/null &

aprun -n 1 -p Yubo-test ./test_reader DATASPACES 1 3 1 1 1 64 64 64 20 2 > reader.log 2>&1 < /dev/null &

wait
