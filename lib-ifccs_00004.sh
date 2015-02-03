#!/bin/bash
# Copyrighted (C) BSD Licence
# This is ongoing implementation of proposed IFCCS-00004 - see e.g. ifccs_00004.txt here


# section A

TMPDIR1="$TMPDIR"

if [[ "$TMPDIR1" == "/" ]] ; then
	:
else
	TMPDIR1=${TMPDIR1%/} # remove trailing /
fi
if [[ -z "$TMPDIR1" ]] ; then 
	TMPDIR1="/tmp"
fi

newend="/user.$USER"
# TODO what if newend from $USER contains special characters like dot
if [[ "$TMPDIR1" == *"$newend" ]] ; then # TMPDIR1 already is /tmp/user.bob
	newtmpdir="$TMPDIR1" # no change
else
	if [[ "$TMPDIR1" == "/" ]] ; then
		newtmpdir="/user.$USER"
	else
		newtmpdir="$TMPDIR1/user.$USER"
	fi
fi

#echo "Using newtmpdir=$newtmpdir"

mkdir -p "$newtmpdir" -m 700
chmod 700 "$newtmpdir"
TMPDIR="$newtmpdir"
export TMPDIR
echo "Using TMPDIR=$TMPDIR"

