#!/bin/bash
# Do NOT call this directly, see readme. See and update build-system.txt

printf "%s\n" "Generating environment"

file_rc="$HOME/.mempo/secret/rc.ini"
if [[ -r "$file_rc" ]] ; then
	source "$file_rc" || { echo "The local secret settings file is present in file_rc=($file_rc) but it can not be sourced into bash" ; exit 1 ; }
fi

if [[ "$LOCAL_SEED" != "" ]] ; then
	export LOCAL_SEED_was_used="yes"
	echo "*************************************** #############################"
	LOCAL_SEED_sum="$( echo "$LOCAL_SEED" | sha256sum | cut -c 1-10 )"
	LOCAL_SEED_peek="${LOCAL_SEED:0:3}"
	echo "You are using custom LOCAL_SEED=(${LOCAL_SEED_peek}...) with sum=(${LOCAL_SEED_sum}...)."
	echo "Therefore YOUR builds will be reproducible (as long as you written down the secret seed), but"
	echo "they will be different then builds done by people who do not know your LOCAL_SEED"
	echo "*************************************** #############################"
else
	LOCAL_SEED=""
fi
echo "LOCAL_SEED_was_used=$LOCAL_SEED_was_used"

source $(dirname $0)/env-data.sh # *** loads the static settings/configuration ***
# conversions etc (do not change this)
export TIMESTAMP_RFC3339=$KERNEL_DATE
export KERNEL_DATE_nice=$( echo $KERNEL_DATE | sed -e 's/ /_/g' )
export MEMPO_RAND_SEED_FILE="$PWD/mempo-generated-seed.txt"

MEMPO_RAND_SEED_SEED="mempo-$KERNEL_DATE_nice-$DEBIAN_REVISION-${CURRENT_SEED}${LOCAL_SEED}"
unset LOCAL_SEED # remove the local secret

echo -n "" > $MEMPO_RAND_SEED_FILE # erase the file
echo -n "$MEMPO_RAND_SEED_SEED-round1" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round2" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round3" | sha256sum - >> $MEMPO_RAND_SEED_FILE
echo -n "$MEMPO_RAND_SEED_SEED-round4" | sha256sum - >> $MEMPO_RAND_SEED_FILE

MEMPO_RAND_SEED_SEED_sum="$( echo "$MEMPO_RAND_SEED_SEED" | sha256sum | cut -c 1-10 )"
export MEMPO_RAND_SEED_SEED_len="${#MEMPO_RAND_SEED_SEED}"
unset MEMPO_RAND_SEED_SEED

echo " * Generated MEMPO_RAND_SEED in file $MEMPO_RAND_SEED_FILE from SEED_SEED with sum=(${MEMPO_RAND_SEED_SEED_sum}...) len=($MEMPO_RAND_SEED_SEED_len)"

export GRSECURITY_RAND_SEED_FILE=$MEMPO_RAND_SEED_FILE # this is the name of variable used by grsecurity (after our patch)

echo " * GRSECURITY_RAND_SEED_FILE=$GRSECURITY_RAND_SEED_FILE"

