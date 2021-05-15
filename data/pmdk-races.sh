#!/bin/bash
set -e
######################################## Defining variables
#BENCHMARKDIR=~/pmdk
#RESULTDIR=~/results
BENCHMARKDIR=/scratch/nvm/pmdk
RESULTDIR=/scratch/nvm/sosp21-ae/results
BUGDIR=$RESULTDIR/pmdk-races
LOGDIR=$BUGDIR/logs
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR
cd ./src/examples/libpmemobj/map/
# Creating run.sh
echo '#!/bin/bash' > run.sh
echo 'export NDCTL_ENABLE=n' >> run.sh
echo 'export LD_LIBRARY_PATH=/scratch/nvm/pmcheck/bin/:/scratch/nvm/pmdk/src/debug' >> run.sh
echo 'export DYLD_LIBRARY_PATH=/scratch/nvm/pmcheck/bin/' >> run.sh
echo 'export PMCheck="-d$3 -y -x25 -r1000"' >> run.sh
echo '$@' >> run.sh
chmod +x run.sh

# Run btree
BENCHMARKNAME=btree
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Run ctree
sed -i '5s/export PMCheck.*/export PMCheck="-d$3 -y -x100 -r1000"/' run.sh
BENCHMARKNAME=ctree
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Run rbtree
BENCHMARKNAME=rbtree
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Run hashmap_atomic
BENCHMARKNAME=hashmap_atomic
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Run hashmap_tx
BENCHMARKNAME=hashmap_tx
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
