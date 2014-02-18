#!/bin/bash
# place for extra settings that could change between releases, and with updates of code and versions

# general:
export kernel_general_version="3.2.55" # script uses this setting

# deterministic build:
export KERNEL_DATE='2014-02-16 23:30:00' # UTC time of mempo version. This is > then max(kernel,grsec,patches) times
# Nothing up my sleeve number, unknown in advance even to me in a provable way - e.g. bitcoin markel root of recent block. 
export CURRENT_SEED='f6ea361192adf9b1619b82e081d4eb44ca2b422d3751d7862bad6ac27fdd00e6' 
# http://blockchain.info/block-index/468735/0000000000000000acecd3ee5fa8d771220e75a018b530378aeb42e984630f2f

# debian make-kpkg related:
export DEBIAN_REVISION="02" # see README.md how to update it on git tag, on rc and final releases

# conversions etc (do not change this)
export TIMESTAMP_RFC3339=$KERNEL_DATE

export MEMPO_RAND_SEED_FILE="$PWD/mempo-generated-seed.txt"
export MEMPO_RAND_SEED_SEED="mempo-$KERNEL_DATE-$DEBIAN_REVISION-$CURRENT_SEED"

echo -n "" > $MEMPO_RAND_SEED_FILE # erase the file
echo -n "$MEMPO_RAND_SEED_SEED-round1" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round2" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round3" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round4" | sha256sum - >> $MEMPO_RAND_SEED_FILE

echo " * Generated MEMPO_RAND_SEED in file $MEMPO_RAND_SEED_FILE from $MEMPO_RAND_SEED_SEED"

