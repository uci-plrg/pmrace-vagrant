#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
#RESULTDIR=~/results
BENCHMARKDIR=/scratch/nvm/memcached-pmem
RESULTDIR=/scratch/nvm/sosp21-ae/results
BUGDIR=$RESULTDIR/memcached-races
LOGDIR=$BUGDIR/logs
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR

# Run Server
sed -i '8s/export PMCheck.*/export PMCheck="-dfoo -x2 -p1 -y -e -r2000"/' run.sh
BENCHMARKNAME=memcached-pmem
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./memcached | tee $TREELOG
grep 'ERROR' $TREELOG &> $BUGDIR/$BENCHMARKNAME-races.log