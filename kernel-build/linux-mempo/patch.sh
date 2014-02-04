#!/bin/bash -e
#to be executed by another script.

. ../../support.sh

linuxdir="$1"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit_error
fi

linuxfile="$linuxdir.tar"

if [ -d "$linuxdir" ] ; then
	echo "EXIT the directory already exists. Please delete it first. linuxdir=$linuxdir"
	exit_error
fi

echo "Unpacking/patching sources: $linuxfile"
tar -xf "$linuxfile" || { echo "Can not unpack linuxfile=$linuxfile" ; exit_error; }

(
	echo "Entering Linux sources in $linuxdir"
	cd "$linuxdir" || { echo "ERROR can not enter directory"; exit_error; }

	mkdir -p ../buildlog || { echo "ERROR can not create buildlog"; exit_error; }

	while IFS=, read -r kind reserved1 reserved2 subdir filename hash_type hash localdir
	do
		if [ "$kind" == "P" ] ; then
			echo -n " # patching with: ${filename}... "
			patch -p1 < "../${localdir}${filename}" &> ../buildlog/${filename}.result \
				|| { echo "ERROR: Patch failed ($filename). " ; exit_error ; }
			echo " DONE ($filename)"
		fi
	done < ../sources.list
	echo "Done patching"
)
err=$? ; if [[ $err != 0 ]] ; then exit_error $err; fi

echo "Done with $linuxdir patching"

