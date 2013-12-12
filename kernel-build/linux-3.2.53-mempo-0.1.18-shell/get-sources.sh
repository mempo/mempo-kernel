#!/bin/bash -e

base=../../kernel-sources

echo "Getting sources (and verifying checksums) for kernel and patches, from base=$base"

function get_and_check() {
	relpath="$1" # relative patch like "grsecurity/", "kernel/ck/" etc, with no slash nor dots.
	filename="$2" # bare file name no slashes,dots etc

	echo -n " # $relpath/$filename - "

	match='^[-a-zA-Z0-9+_]+[-.a-zA-Z0-9+_]*$'; s="$filename" ; [[ "$s" =~ $match ]] || { echo "ERROR bogous file name ($s)"; exit 1 ; }
	match='^[-a-zA-Z0-9_]+$'; s="$relpath" ; [[ "$s" =~ $match ]] || { echo "ERROR bogous subdir name ($s)"; exit 1 ; } # no dots at all, to avoid foo/../ with simple regexp
	# no funny business.

	hash_type=$3
	if [[ "$hash_type" != "sha256" ]] ; then 
		echo "*** ERROR Unsupported hash_type=$hash_type." ; exit 1
	fi
	checksum_expected=$4

	filefull="${base}/${relpath}/${filename}"
	if [ ! -d "tmp/" ] ; then
		mkdir tmp
	fi
	cp "$filefull" "tmp/"
	checksum_now=`sha256sum "tmp/${filename}" | cut -d" " -f 1`
	if [[ "$checksum_now" != "$checksum_expected" ]]
	then
		echo "*** ERROR: unexpected checksum for the file ($filename) from ${filefull}"
		echo "Checksum is: $checksum_now"
		echo "Expected   : $checksum_expected"
		echo "This can be truncated download, corrupted media/file, or attempt to troyan you!"
		echo "Back up this file here tmp/${filename} for futher analysis and report to proper IT staff"
		exit 1
	fi
	checksum_now_short="${checksum_now:0:16}"
	echo " OK ($checksum_now_short... as expected) "
	mkdir -p "${localdir}"
	mv  "tmp/${filename}"  "${localdir}${filename}"
}

echo "Processing sources list"
while IFS=, read -r kind reserved1 reserved2 subdir filename hash_type hash localdir
do
	get_and_check "$subdir" "$filename" "$hash_type" "$hash" "$localdir"
done < sources.list
echo "Sources list completed"

if [ -d "tmp/" ] ; then
	rm -rf "tmp/"
fi

echo "=== Sources are now patched and ready to be builded === "

