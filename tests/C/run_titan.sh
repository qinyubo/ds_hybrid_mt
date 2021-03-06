#!/bin/bash
#PBS -A CSC143TITAN
#PBS -N ds_mt_debug
#PBS -j eo
#PBS -q debug
#PBS -l walltime=00:3:00
#PBS -l nodes=3
#PBS -M qybo123@gmail.com

cd /lustre/atlas/scratch/subedip1/csc143/yubo/dataspaces/tests/C
rm -rf conf* srv.lck*
rm -rf dataspaces.conf

DIR=.

SERVER=dataspaces_server
WRITER=test_writer
READER=test_reader

CONF_DIMS_1=16384
CONF_DIMS_2=16384

NUM_SERVER=1
NUM_WRITER=4
NUM_READER=4

let "DW=CONF_DIMS_1/NUM_WRITER"
let "DR=CONF_DIMS_1/NUM_READER"

rm -f conf cred dataspaces.conf srv.lck
#bash /home1/yq47/code/dataspace/dataspaces_service_clean/tests/C/cleanall.sh

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS_1, $CONF_DIMS_2

max_versions = 1
lock_type = 2
" > dataspaces.conf


## Run DataSpaces servers
aprun -n $NUM_SERVER -N $NUM_SERVER $DIR/$SERVER -s $NUM_SERVER -c $(($NUM_WRITER+$NUM_READER)) >> server.log 2>&1 < /dev/null &
DSPID=$!

## Give some time for the servers to load and startup
while [ ! -f conf ]; do
    sleep 1s
done
sleep 2s  # wait server to fill up the conf file

## Run writer application
aprun -n $NUM_WRITER $DIR/$WRITER DATASPACES $NUM_WRITER 2 $NUM_WRITER 1 $(($CONF_DIMS_1/$NUM_WRITER)) $CONF_DIMS_2 5 1 >> writer.log 2>&1 < /dev/null &

## Run reader application
aprun -n $NUM_READER $DIR/$READER DATASPACES $NUM_READER 2 $NUM_READER 1 $(($CONF_DIMS_1/$NUM_READER)) $CONF_DIMS_2 5 2 >> reader.log 2>&1 < /dev/null & 

wait
#kill DS Server ##
kill ${DSPID}
