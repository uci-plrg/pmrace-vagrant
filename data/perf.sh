#!/bin/bash
set -e


## Setup
RESULTDIR=~/results
OUTFILE=$RESULTDIR/random-performance.csv
LOG=~/log.log
mkdir -p $RESULTDIR
echo 'Benchmark, Baseline(s), PMRace(s), # Prefix Bugs, # Naive Bugs' > $OUTFILE
GCCCOMPILER=/home/vagrant/pmcheck-vmem/Test/gcc
GXXCOMPILER=/home/vagrant/pmcheck-vmem/Test/g++


## RECIPE evaluation for -x1
BENCHMARKDIR=~/nvm-benchmarks/RECIPE
cd $BENCHMARKDIR

run_CCEH() {
	BENCHMARKNAME=CCEH
	cd $BENCHMARKNAME
	echo "Compiling $BENCHMARKNAME ..."
	git checkout -- run.sh
	sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLWB=1/' Makefile
	sed -i '3iexport PMCheck="-x1"' run.sh
	make &> /dev/null
	echo "Running $BENCHMARKNAME on Jaaru ..."
	start=`date +%s.%N`
	for i in {1..100}; do
		./run.sh ./example 30 4 &> /dev/null
	done
	end=`date +%s.%N`
	JAARU=$( echo "$end/100 - $start/100" | bc -l )
	sed -i '3s/export PMCheck.*/export PMCheck="-x1 -y"/' run.sh
	echo "Running $BENCHMARKNAME on PMRace ..."
	./run.sh ./example 30 4 &> $LOG
	start=`date +%s.%N`
	for i in {1..100}; do
		./run.sh ./example 30 4 &> /dev/null
	done
	end=`date +%s.%N`
	PMRACE=$( echo "$end/100 - $start/100" | bc -l )
	PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
	NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
	echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
	# Cleaning up
	sed -i '3d' run.sh
	sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLFLUSH_OPT=1/' Makefile
	make clean &> /dev/null
	cd ..
}

run_RECIPE() {
	run_CCEH
}

run_RECIPE

## Cleanup
rm -f $LOG
cat $OUTFILE | sed 's/,/ ,/g' | column -t -s, | less -S
