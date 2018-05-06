#!/bin/bash
DIR=.
CONF_DIMS_1=128
CONF_DIMS_2=128

#CONF_DIMS_1=16384
#CONF_DIMS_2=16384

NUM_SERVER=1
NUM_WRITER=1
NUM_READER=0

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf

mpirun -machinefile cal_server --bind-to socket -n $NUM_SERVER $DIR/dataspaces_server -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER))  & sleep 2
mpirun -machinefile cal_server --bind-to socket -n $NUM_WRITER $DIR/test_rw DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 1 1 &


wait 

