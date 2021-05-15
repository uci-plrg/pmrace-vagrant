#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
#RESULTDIR=~/results
BENCHMARKDIR=/scratch/nvm/redis-nvml
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
# Run client
./testcase/redistestcase.sh 0 | ./run2.sh ./src/redis-cli
