#!/bin/bash -e
# do NOT run this directly, run build-run.sh

linuxdir="$1"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit 1
fi

echo "Building linuxdir=$linuxdir"

echo "Creating sources info"
bash $HOME/make-source-info

echo "Loading env"
. env.sh
export CONCURRENCY_LEVEL=8 
export BUILD_NICENESS=0

echo "Starting build in $linuxdir"

pwd_here=$PWD

	echo "CONCURRENCY_LEVEL=$CONCURRENCY_LEVEL"
	echo "Will faketime: $TIMESTAMP_RFC3339"


	echo "Entering Linux sources in $linuxdir"
	cd "$linuxdir"

	rm -rf ../buildlog ; mkdir -p ../buildlog

	echo -n "Calculating checksum of the system: "
	rm -f "../system_id.txt"
	system_id=`sha256deep -l -r kernel/ kernel-img.conf  kernel-pkg.conf | sort | sha256sum | cut -d" " -f1 `
	echo "$system_id"
	echo "$system_id" > "../system_id.txt"

	echo -n "Calculating checksum of the sources: "
	rm -f "../sources_id.txt"
	sources_id=`sha256deep -l -r "." | sort | sha256sum | cut -d" " -f1 `
	echo "$sources_id"
	echo "$sources_id" > "../sources_id.txt"

 	cp ../configs/config-good.config .config || { echo "ERROR Could not copy the ../config file here." ; exit 1 ; }
	config_id=`sha256sum .config | cut -d" " -f1`
	echo "Using .config with ID=$config_id"
	echo $PWD
	echo ""
	echo "=== BUILD MAIN ================================="

	cores_max_autodetect=32 # TODO configure this? e.g. from amount of RAM available

	if [[ -z $CONCURENCY_LEVEL ]] ; then
		echo "Will try to auto-detect proper CONCURENCY_LEVEL since none was set in variable"
		cores=2
		if command -v nproc 2>/dev/null 
		then
			cores=$(nproc 2>&1)	
			if (( $cores > $cores_max_autodetect )) ; then
				cores=$cores_max_autodetect
				echo "Limied to cores=$cores (because free RAM limitation) you can override by setting CONCURENCY_LEVEL env"
			fi
		else 
			echo "Warning: can not detect number of CPUs to optimize build speed, please configure CONCURENCY_LEVEL variable if you want"
		fi
		CONCURENCY_LEVEL=$cores
	fi

	ccache_path_dir="/usr/lib/ccache"
	if [ -d "$ccache_path_dir" ] ; then
		echo "Detected ccache directory, adding to path: $ccache_path_dir"
		PATH="$ccache_path_dir:$PATH"
	fi

	overlay_dir="$HOME/deterministic-kernel/overlay-dir/"
	overlay_dir="${pwd_here}/../../overlay-dir"
	if [ ! -d $overlay_dir ] ; then
		echo "ERROR: The overlay_dir=$overlay_dir is not existing directory!"
		exit 1
	fi
#	echo $overlay_dir
#	echo $PWD
#	echo "IN BASH"
#	bash
#	echo "DONE BASH"
	echo "* Using CONCURRENCY_LEVEL=$CONCURRENCY_LEVEL"
	echo "* Using PATH=$PATH"
	echo "* Using overlay_dir=$overlay_dir"

	set -x
	faketime "$TIMESTAMP_RFC3339"	nice -n "$BUILD_NICENESS" time make-kpkg --rootcmd fakeroot kernel_image kernel_headers kernel_debug  kernel_doc kernel_manual  --initrd --revision "$DEBIAN_REVISION" --overlay-dir "$overlay_dir" 2>1 | tee ../buildlog/build.result
	set +x

	# faketime "$TIMESTAMP_RFC3339"	nice -n "$BUILD_NICENESS" time make-kpkg --rootcmd fakeroot kernel_image kernel_headers kernel_debug  kernel_doc kernel_manual  --initrd --revision "$DEBIAN_REVISION" --overlay-dir $overlay-dir 2>1 | tee ../buildlog/build.result
	# faketime "$TIMESTAMP_RFC3339"	nice -n "$BUILD_NICENESS" time make-kpkg --rootcmd fakeroot kernel_image kernel_headers kernel_debug  kernel_doc kernel_manual  --initrd --revision "$DEBIAN_REVISION" --overlay-dir ~/deterministic-kernel/overlay-dir 2>1 | tee ../buildlog/build.result
	
	echo "... returned from the main BUILD program"
	echo
	date
	echo "================================================"

cd $pwd_here

echo 
echo "Done building in $linuxdir"
