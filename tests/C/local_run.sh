#!/bin/bash
DIR=.
CONF_DIMS=1024

rm -f conf cred dataspaces.conf srv.lck

echo "## Config file for DataSpaces
ndim = 2
dims = $CONF_DIMS, $CONF_DIMS

max_versions = 1
lock_type = 2
" > dataspaces.conf

#./dataspaces_server -s 4 -c 72 & sleep 2

#./test_writer DATASPACES 64 3 4 4 4 256 256 256 2 1 > test_writer.out 2>&1 &
#./test_reader DATASPACES 8 3 4 2 1 256 512 1024 2 2 > test_reader.out 2>&1 &

mpirun -n 1 ./dataspaces_server -s 1 -c 5 >& $DIR/server_$CONF_DIMS.log & SERVER_PID=$!
echo "SERVER_PID: $SERVER_PID"
sleep 2

mpirun -n 4 $DIR/test_writer DATASPACES 4 2 4 1 $CONF_DIMS/4 $CONF_DIMS 3 1 > $DIR/writer_$CONF_DIMS.log 2>&1 &
mpirun -n 1 $DIR/test_reader DATASPACES 1 2 1 1 $CONF_DIMS $CONF_DIMS 3 2 > $DIR/reader_$CONF_DIMS.log 2>&1 & READER_PID=$!
#mpirun -n 4 $DIR/test_writer DATASPACES 4 2 4 1 512 2048 5 1 > $DIR/writer_$CONF_DIMS.log 2>&1 &
#mpirun -n 1 $DIR/test_reader DATASPACES 1 2 1 1 2048 2048 5 2 > $DIR/reader_$CONF_DIMS.log 2>&1 &
#mpirun -n 4 $DIR/test_writer DATASPACES 4 2 4 1 256 1024 5 1 > $DIR/writer_$CONF_DIMS.log 2>&1 &
#mpirun -n 1 $DIR/test_reader DATASPACES 1 2 1 1 1024 1024 5 2 > $DIR/reader_$CONF_DIMS.log 2>&1 &

wait $READER_PID
sleep 3
kill -9 $SERVER_PID
