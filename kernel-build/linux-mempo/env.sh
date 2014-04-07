#!/bin/bash
# place for extra settings that could change between releases, and with updates of code and versions

# general:
export kernel_general_version="3.2.56" # script uses this setting

# deterministic build:
export KERNEL_DATE='2014-04-07 08:53:00' # UTC time of mempo version. This is > then max(kernel,grsec,patches) times
# Nothing up my sleeve number, unknown in advance even to me in a provable way - e.g. bitcoin markel root of recent block. 
export CURRENT_SEED='fc36a8e1befee61ff5c5d1ca9b90234f2f5d2cd956d73f25c63bd23fbd33ba87' # from newest (at release, -6 blocks) http://blockchain.info/block-index/ or http://blockexplorer.com/
# debian make-kpkg related:
export DEBIAN_REVISION="01" # see README.md how to update it on git tag, on rc and final releases

# conversions etc (do not change this)
export TIMESTAMP_RFC3339=$KERNEL_DATE

KERNEL_DATE_nice=$( echo $KERNEL_DATE | sed -e 's/ /_/g' )

export MEMPO_RAND_SEED_FILE="$PWD/mempo-generated-seed.txt"
export MEMPO_RAND_SEED_SEED="mempo-$KERNEL_DATE_nice-$DEBIAN_REVISION-$CURRENT_SEED"

echo -n "" > $MEMPO_RAND_SEED_FILE # erase the file
echo -n "$MEMPO_RAND_SEED_SEED-round1" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round2" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round3" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round4" | sha256sum - >> $MEMPO_RAND_SEED_FILE

echo " * Generated MEMPO_RAND_SEED in file $MEMPO_RAND_SEED_FILE from $MEMPO_RAND_SEED_SEED"

export GRSECURITY_RAND_SEED_FILE=$MEMPO_RAND_SEED_FILE # this is the name of variable used by grsecurity (after our patch)

echo " * GRSECURITY_RAND_SEED_FILE=$GRSECURITY_RAND_SEED_FILE"

