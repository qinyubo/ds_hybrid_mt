#!/bin/bash
#COBALT -t 00:20:00
#COBALT -n 70
#COBALT -A DataSpaces
#COBALT -q default

##########################################
#	2 thread, Multi-thread version
#
##########################################
SERVER=dataspaces_server_thrd_2
WRITER=test_writer_thrd_2
READER=test_reader_thrd_2

echo "Start 2 thread 16:1:16"


##### 16:1:16 #############
DIR=.
CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=1
NUM_WRITER=16
NUM_READER=16

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

echo " " >> writer.log
echo " " >> writer.log
echo "writer:server:reader  16:1:16" >> writer.log
echo " " >> writer.log

echo " " >> reader.log
echo " " >> reader.log
echo "writer:server:reader  16:1:16" >> reader.log
echo " " >> reader.log

#dedicate staging, 1 MPI process per node
aprun -n $NUM_SERVER -N 1 -d 2 -p Yubo-test $DIR/$SERVER -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >> server.log 2>&1 < /dev/null & SERVER_PID=$!

sleep 5

aprun -n $NUM_WRITER -p Yubo-test $DIR/$WRITER DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 >> writer.log 2>&1 < /dev/null &

aprun -n $NUM_READER -p Yubo-test $DIR/$READER DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 >> reader.log 2>&1 < /dev/null & READER_PID=$!

wait $READER_PID
sleep 3
kill -9 $SERVER_PID

echo "Finish 2 thread 16:1:16"

##### 16:2:16 #############
DIR=.
CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=2
NUM_WRITER=16
NUM_READER=16

echo "Start 2 thread 16:2:16"

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

echo " " >> writer.log
echo " " >> writer.log
echo "writer:server:reader  16:2:16" >> writer.log
echo " " >> writer.log

echo " " >> reader.log
echo " " >> reader.log
echo "writer:server:reader  16:2:16" >> reader.log
echo " " >> reader.log

#dedicate staging, 1 MPI process per node
aprun -n $NUM_SERVER -N 2 -d 2 -p Yubo-test $DIR/$SERVER -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >> server.log 2>&1 < /dev/null & SERVER_PID=$!

sleep 5

aprun -n $NUM_WRITER -p Yubo-test $DIR/$WRITER DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 >> writer.log 2>&1 < /dev/null &

aprun -n $NUM_READER -p Yubo-test $DIR/$READER DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 >> reader.log 2>&1 < /dev/null & READER_PID=$!

wait $READER_PID
sleep 3
kill -9 $SERVER_PID

echo "Finish 2 thread 16:2:16"


##### 32:1:32 #############
DIR=.
CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=1
NUM_WRITER=32
NUM_READER=32

echo "Start 2 thread 32:1:32"

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

echo " " >> writer.log
echo " " >> writer.log
echo "writer:server:reader  32:1:32" >> writer.log
echo " " >> writer.log

echo " " >> reader.log
echo " " >> reader.log
echo "writer:server:reader  32:1:32" >> reader.log
echo " " >> reader.log

#dedicate staging, 1 MPI process per node
aprun -n $NUM_SERVER -N 1 -d 2 -p Yubo-test $DIR/$SERVER -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >> server.log 2>&1 < /dev/null & SERVER_PID=$!

sleep 5

aprun -n $NUM_WRITER -p Yubo-test $DIR/$WRITER DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 >> writer.log 2>&1 < /dev/null &

aprun -n $NUM_READER -p Yubo-test $DIR/$READER DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 >> reader.log 2>&1 < /dev/null & READER_PID=$!

wait $READER_PID
sleep 3
kill -9 $SERVER_PID

echo "Finish 2 thread 32:1:32"

##### 32:2:32 #############
DIR=.
CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=2
NUM_WRITER=32
NUM_READER=32

echo "Start 2 thread 32:2:32"

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

echo " " >> writer.log
echo " " >> writer.log
echo "writer:server:reader  32:2:32" >> writer.log
echo " " >> writer.log

echo " " >> reader.log
echo " " >> reader.log
echo "writer:server:reader  32:2:32" >> reader.log
echo " " >> reader.log

#dedicate staging, 1 MPI process per node
aprun -n $NUM_SERVER -N 2 -d 2 -p Yubo-test $DIR/$SERVER -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >> server.log 2>&1 < /dev/null & SERVER_PID=$!

sleep 5

aprun -n $NUM_WRITER -p Yubo-test $DIR/$WRITER DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 >> writer.log 2>&1 < /dev/null &

aprun -n $NUM_READER -p Yubo-test $DIR/$READER DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 >> reader.log 2>&1 < /dev/null & READER_PID=$!

wait $READER_PID
sleep 3
kill -9 $SERVER_PID

mkdir thrd_version
mv server.log writer.log reader.log ./thrd_version

echo "Finish 2 thread 32:2:32"

sleep 2

echo "DONE!"

