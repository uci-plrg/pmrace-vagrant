#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
BENCHMARKDIR=/scratch/nvm/redis-nvml
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
# Run client
./testcase/memcachedtestcase.sh 0 | telnet localhost 11211