#!/bin/bash
#COBALT -t 00:02:00
#COBALT -n 3
#COBALT -A DataSpaces
#COBALT -q debug-cache-quad


DIR=.
CONF_DIMS=512

rm -f conf cred dataspaces.conf srv.lck

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS, $CONF_DIMS

max_versions = 1
lock_type = 2
" > dataspaces.conf


#export DSPACES_GNI_PTAG=255
#export DSPACES_GNI_COOKIE=0x3df10000

#echo "I can run!"
#./try
aprun -n 1 -p Yubo-test $DIR/dataspaces_server -s 1 -c 2 > server.log 2>&1 < /dev/null & sleep 2

aprun -n 1 -p Yubo-test $DIR/test_writer DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 1 1 > writer.log 2>&1 < /dev/null &
aprun -n 1 -p Yubo-test $DIR/test_reader DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 1 2 > reader.log 2>&1 < /dev/null &
wait


