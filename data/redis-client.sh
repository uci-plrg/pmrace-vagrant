#!/bin/bash
set -e

BENCHMARKDIR=~/nvm-benchmarks/redis
cp $BENCHMARKDIR/run.sh $BENCHMARKDIR/run2.sh
sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -y -e -r2000"/' $BENCHMARKDIR/run2.sh
# 1. Run pre-crash client
./testcase/redistestcase.sh 1 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli

sleep 10
# 2. Run post-crash client
./testcase/redistestcase.sh 0 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli
