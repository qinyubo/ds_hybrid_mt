#!/bin/bash
DIR=.
CONF_DIMS=1024

bash $DIR/cleanall.sh

#kill all previous dataspaces process
ps -aux | grep dataspaces| cut -c 9-15|xargs kill -9
ps -aux | grep test| cut -c 9-15|xargs kill -9

rm -f conf cred dataspaces.conf srv.lck

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS, $CONF_DIMS

max_versions = 1
lock_type = 2
" > dataspaces.conf


mpirun -n 1 $DIR/dataspaces_server -s 1 -c 5 & sleep 2
mpirun -n 4 $DIR/test_writer DATASPACES 4 2 4 1 $CONF_DIMS/4 $CONF_DIMS 1 1  &
mpirun -n 1 $DIR/test_reader DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 1 2  &

#mpirun -n 1 $DIR/dataspaces_server -s 1 -c 2 & sleep 2
#mpirun -n 1 $DIR/test_writer DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 1 1  &
#mpirun -n 1 $DIR/test_reader DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 1 2  &
wait