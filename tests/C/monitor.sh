#!/bin/bash

while [ ! -f server.log ]; do
    sleep 1s
done

tail -f server.log
