#!/bin/bash
DIR=.
CONF_DIMS_1=8192
CONF_DIMS_2=8192

#CONF_DIMS_1=16384
#CONF_DIMS_2=16384

NUM_SERVER=1
NUM_WRITER_TOT=1
NUM_READER_TOT=1
NUM_WRITER=1
NUM_READER=1

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

mpirun -machinefile cal_server --bind-to socket -n $NUM_SERVER $DIR/dataspaces_server -s $NUM_SERVER -c $(($NUM_WRITER_TOT+$NUM_READER_TOT)) & sleep 2
mpirun -machinefile cal_server --bind-to socket -n $NUM_WRITER $DIR/test_writer_1 DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 2 1 8 1 0 &
mpirun -machinefile cal_server --bind-to socket -n $NUM_READER $DIR/test_reader_1 DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 2 3 8 1 0 

mpirun -machinefile cal_server --bind-to socket -n $NUM_WRITER $DIR/test_writer_2 DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 2 2 8 1 1  &

mpirun -machinefile cal_server --bind-to socket -n $NUM_READER $DIR/test_reader_2 DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 2 4 8 1 1 

#gdb $DIR/dataspaces_server -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER))  & sleep 2
#mpirun -n $NUM_WRITER $DIR/test_writer DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 2 1 &
#mpirun -n $NUM_READER $DIR/test_reader DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 2 2 &

#mpirun -machinefile cal_server -n $NUM_SERVER $DIR/dataspaces_server -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >& $DIR/server_$CONF_DIMS_1.log & sleep 2
#mpirun -machinefile cal_server -n $NUM_WRITER $DIR/test_writer DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 1 1 >& $DIR/writer_$CONF_DIMS_1.log &
#mpirun -machinefile cal_server -n $NUM_READER $DIR/test_reader DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 1 2 >& $DIR/reader_$CONF_DIMS_1.log &

#time mpirun -machinefile hostfile.txt -n 2 $DIR/dataspaces_server -s 2 -c 16 >& $DIR/server_$CONF_DIMS.log & SERVER_PID=$!  sleep 2
#mpirun -machinefile hostfile.txt -n 8 $DIR/test_writer DATASPACES 8 2 8 1 $CONF_DIMS/8 $CONF_DIMS 5 1  > $DIR/writer_$CONF_DIMS.log 2>&1 &
#mpirun -machinefile hostfile.txt -n 8 $DIR/test_reader DATASPACES 8 2 8 1 $CONF_DIMS/8 $CONF_DIMS 5 2  > $DIR/reader_$CONF_DIMS.log 2>&1 & READER_PID=$!

wait 

#wait $READER_PID
#sleep 3
#kill -9 $SERVER_PID

# 