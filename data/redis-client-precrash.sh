#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
BENCHMARKDIR=/scratch/nvm/redis-nvml
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
cp run.sh run2.sh
# Run client
sed -i '6s/export PMCheck.*/export PMCheck="-d/ramfs/redis.pm -x1 -p1 -y -e -r2000"/' run2.sh
./testcase/redistestcase.sh 1 | ./run2.sh ./src/redis-cli