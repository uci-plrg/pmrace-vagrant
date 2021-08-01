#!/bin/bash
set -e

BENCHMARKDIR=~/nvm-benchmarks/redis
# 1. Run pre-crash client
./testcase/redistestcase.sh 1 | $BENCHMARKDIR/run.sh $BENCHMARKDIR/src/redis-cli

sleep 10
# 2. Run post-crash client
./testcase/redistestcase.sh 0 | $BENCHMARKDIR/run.sh $BENCHMARKDIR/src/redis-cli
