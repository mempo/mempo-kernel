#!/bin/bash

# Test do we have needed tool chain programs 

all_ok=1

echo "Looking for toolchian..."

echo "Checks DISABLED for now (TODO), assuming you are using the correct tar."
echo "(Will check in other place probably)"
echo ""
#PATH="$HOME/.local/bin:$PATH"
#PATH="$HOME/.local/usr/bin:$PATH"

if false ; then

touch testfile.txt
tar --mtime "2013-12-24 23:59:01" --sort-input  -c -f testfile.tar testfile.txt
exitcode=$?
rm -f testfile.txt ; rm -f testfile.tar

if [[ 0 == "$exitcode" ]]  ; then
	echo "Ok, the global tar supports extended options"
fi

if [[ 0 != "$exitcode" ]]  ; then
  PATH="$HOME/.local/usr/bin/:$PATH"
	echo "Trying with other PATH=$PATH"

	touch testfile.txt
	tar --mtime "2013-12-24 23:59:01" --sort-input  -c -f testfile.tar testfile.txt
	exitcode=$?
	rm -f testfile.txt ; rm -f testfile.tar

	if [[ 0 == "$exitcode" ]]  ; then
		echo "Ok, the tar supports extended options"
	else
		echo "" ; echo "ERROR:"
		echo "Can not find extended tar with support for --sort-input"
		echo "Please install it from: "
		echo "  https://github.com/mempo/mempo-deb/ once this is ready, or while not available use:"
		echo "  https://github.com/mempo/various/tree/master/tar once this is ready, or while not available use:"
		exit 1 # error
	fi
fi

# TODO test also /opt/ and /usr/local/ ?

echo "Final PATH=$PATH"

# export FAKETIME_TIME="$TIMESTAMP_RFC3339" ; # '1970-12-30 18:00:01'

fi


