#!/bin/bash
#COBALT -t 00:05:00
#COBALT -n 5
#COBALT -A DataSpaces
#COBALT -q debug-cache-quad

DIR=.
CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=2
NUM_WRITER=2
NUM_READER=2

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

aprun -n $NUM_SERVER -p Yubo-test $DIR/dataspaces_server -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) > server.log 2>&1 < /dev/null & SERVER_PID=$!

sleep 5

aprun -n $NUM_WRITER -p Yubo-test $DIR/test_writer DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 > writer.log 2>&1 < /dev/null &

aprun -n $NUM_READER -p Yubo-test $DIR/test_reader DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 > reader.log 2>&1 < /dev/null & READER_PID=$!

wait $READER_PID
sleep 3
kill -9 $SERVER_PID








