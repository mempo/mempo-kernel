#!/bin/bash -e
# Do NOT call this directly, see readme. See and update build-system.txt

source ../../support.sh

print_ok_header "Patch"
echo "kernel_config_name=$kernel_config_name"

linuxdir="$1"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit_error
fi

linuxfile="$linuxdir.tar"

if [ -d "$linuxdir" ] ; then
	echo "EXIT the directory already exists. Please delete it first. linuxdir=$linuxdir"
	exit_error
fi

echo "Unpacking/patching sources: $linuxfile, using filter kernel_patch_id_filter=$kernel_patch_id_filter"
tar -xf "$linuxfile" || { echo "Can not unpack linuxfile=$linuxfile" ; exit_error; }

(
	echo "Entering Linux sources in $linuxdir"
	cd "$linuxdir" || { echo "ERROR can not enter directory"; exit_error; }

	mkdir -p ../buildlog || { echo "ERROR can not create buildlog"; exit_error; }

	egrep $kernel_patch_id_filter ../sourcecode.list | while IFS=, read -r kind reserved1 reserved2 subdir filename hash_type hash localdir
	do
		if [ "$kind" == "P" ] ; then
			echo -n " # patching with: ${filename}... "
			patch -p1 < "../${localdir}${filename}" &> ../buildlog/${filename}.result \
				|| { echo "ERROR: Patch failed ($filename). " ; exit_error ; }
			echo " DONE ($filename)"
		fi
	done
	echo "Done patching"
)
err=$? ; if [[ $err != 0 ]] ; then exit_error $err; fi

echo "Done with $linuxdir patching"

