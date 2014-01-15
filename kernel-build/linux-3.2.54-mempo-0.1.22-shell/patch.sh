#!/bin/bash -e
#to be executed by another script.

linuxdir="$1"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit 1
fi

linuxfile="$linuxdir.tar"

if [ -d "$linuxdir" ] ; then
	echo "EXIT the directory already exists. Please delete it first. linuxdir=$linuxdir"
	exit 1
fi

echo "Unpacking/patching sources: $linuxfile"
tar -xf "$linuxfile"

(
	echo "Entering Linux sources in $linuxdir"
	cd "$linuxdir" || { echo "ERROR can not enter directory"; exit 1; }

	mkdir -p ../buildlog || { echo "ERROR can not create buildlog"; exit 1; }

	while IFS=, read -r kind reserved1 reserved2 subdir filename hash_type hash localdir
	do
		if [ "$kind" == "P" ] ; then
			echo -n " # patching with: ${filename}... "
			patch -p1 < "../${localdir}${filename}" &> ../buildlog/${filename}.result \
				|| { echo "ERROR: Patch failed ($filename). " ; exit 1 ; }
			echo " DONE ($filename)"
		fi
	done < ../sources.list
	echo "Done patching"
)

echo "Done with $linuxdir patching"

