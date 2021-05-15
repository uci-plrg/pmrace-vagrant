#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
#RESULTDIR=~/results
BENCHMARKDIR=/scratch/nvm/redis-nvml
RESULTDIR=/scratch/nvm/sosp21-ae/results
BUGDIR=$RESULTDIR/redis-races
LOGDIR=$BUGDIR/logs
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR

# Run Server
sed -i '6s/export PMCheck.*/export PMCheck="-d/ramfs/redis.pm -x2 -p1 -y -e -r2000"/' run.sh
BENCHMARKNAME=redis
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./src/redis-server ./redis.conf | tee $TREELOG
grep 'ERROR' $TREELOG &> $BUGDIR/$BENCHMARKNAME-races.log