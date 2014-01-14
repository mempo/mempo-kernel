#!/bin/bash

# Test do we have needed tool chain programs 

all_ok=1

echo "Looking for toolchian..."

touch testfile.txt
tar --faketime "2013-12-24 23:59:01" -c -f testfile.tar testfile.txt
exitcode=$?
rm -f testfile.txt ; rm -f testfile.tar

if [[ 0 == "$exitcode" ]]  ; then
	echo "Ok, the global tar supports extended options"
fi

if [[ 0 != "$exitcode" ]]  ; then
        PATH="$HOME/.local/usr/lib/faketime-wrapper/:$PATH"
	echo "Trying with other PATH=$PATH"

	touch testfile.txt
	tar --faketime "2013-12-24 23:59:01" -c -f testfile.tar testfile.txt
	exitcode=$?
	rm -f testfile.txt ; rm -f testfile.tar

	if [[ 0 == "$exitcode" ]]  ; then
		echo "Ok, the tar supports extended options"
	else
		echo "" ; echo "ERROR:"
		echo "Can not find extended tar with support for --faketime"
		echo "Please install it from: "
		echo "  https://github.com/mempo/mempo-deb/ directory tar, or"
		echo "  https://github.com/rfree/various/tree/master/tar"
		exit 1 # error
	fi
	
fi

echo "Final PATH=$PATH"

# export FAKETIME_TIME="$TIMESTAMP_RFC3339" ; # '1970-12-30 18:00:01'
