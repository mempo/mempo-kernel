#!/bin/bash
# Do NOT call this directly, see readme. See and update build-system.txt

printf "%s\n" "Generating environment"

source $(dirname $0)/env-data.sh # *** loads the static settings/configuration ***

# conversions etc (do not change this)
export TIMESTAMP_RFC3339=$KERNEL_DATE

export KERNEL_DATE_nice=$( echo $KERNEL_DATE | sed -e 's/ /_/g' )

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

