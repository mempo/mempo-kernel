#!/bin/bash -e
# Do NOT call this directly, see readme. See and update build-system.txt

# this is the main inner build script - it executes build directly

source ../../support.sh

linuxdir="$1"
flavour="$2"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit_error
fi

echo "Building linuxdir=$linuxdir"

# TODO
# echo "Creating sources info"
# bash $HOME/make-source-info

echo "Loading env"
source env.sh
export BUILD_NICENESS=0

echo "Starting build in $linuxdir"

pwd_here=$PWD

	cores_max_autodetect=32 # TODO configure this? e.g. from amount of RAM available
	if [[ -z $CONCURRENCY_LEVEL ]] ; then
                echo "Will try to auto-detect proper CONCURENCY_LEVEL since none was set in variable"
		cores=2
		exists=$(command -v nproc 2>/dev/null)
		if [ -n exists ]
                then
                        cores=$(nproc 2>&1)
                        if (( $cores > $cores_max_autodetect )) ; then
                                cores=$cores_max_autodetect
                                echo "Limied to cores=$cores (because free RAM limitation) you can override by setting CONCURENCY_LEVEL env"
                        fi
                else
                        echo "Warning: can not detect number of CPUs to optimize build speed, please configure CONCURENCY_LEVEL variable if you want"
                fi
		export CONCURRENCY_LEVEL=$cores
	fi


	echo "CONCURRENCY_LEVEL=$CONCURRENCY_LEVEL"
	echo "Will faketime: $TIMESTAMP_RFC3339"


	echo "Entering Linux sources in $linuxdir"
	cd "$linuxdir" || { echo "ERROR can not enter $linuxdir"; exit_error; }

	rm -rf ../buildlog ; mkdir -p ../buildlog || { echo "Can not create buildlog"; exit_error; }

	echo -n "Calculating checksum of the system: "
	rm -f "../system_id.txt"
	system_id=`sha256deep -l -r /etc/kernel/ /etc/kernel-img.conf  /etc/kernel-pkg.conf | sort | sha256sum | cut -d" " -f1 `
	echo "$system_id"
	echo "$system_id" > "../system_id.txt"

	echo -n "Calculating checksum of the sources: "
	rm -f "../sources_id.txt"
	sources_id=`sha256deep -l -r "." | sort | sha256sum | cut -d" " -f1 `
	echo "$sources_id"
	echo "$sources_id" > "../sources_id.txt"

	config_name=$flavour
	# TODO check if config_name is plain [a-zA-Z0-9] and >0 length
	use_config_from=../configs/config-${config_name}.config
 	cp $use_config_from .config || { echo "ERROR Could not copy the config=$use_config_from file here in PWD=$PWD, ABORTING" ; exit_error ; }
	config_id=`sha256sum .config | cut -d" " -f1`
	echo "Using .config with ID=$config_id"
	echo $PWD
	echo ""
	echo "=== BUILD MAIN ================================="

	ccache_path_dir="/usr/lib/ccache"
	if [ -d "$ccache_path_dir" ] ; then
		echo "Detected ccache directory, adding to path: $ccache_path_dir"
		PATH="$ccache_path_dir:$PATH"
	else
		echo "WARNING: not using ccache (this is OK, but will take longer overall)"
	fi

	overlay_dir="$HOME/deterministic-kernel/overlay-dir/"
	overlay_dir="${pwd_here}/../../overlay-dir"
	if [ ! -d $overlay_dir ] ; then
		echo "ERROR: The overlay_dir=$overlay_dir is not existing directory!"
		exit_error
	fi

	export KCONFIG_NOTIMESTAMP=1
	export KBUILD_BUILD_TIMESTAMP=`date -u -d "${TIMESTAMP_RFC3339}"`
	export DEB_BUILD_TIMESTAMP=`date -u +%s -d "${TIMESTAMP_RFC3339}"`
	export KBUILD_BUILD_USER=user
	export KBUILD_BUILD_HOST=host
	export ROOT_DEV=FLOPPY
	export FAKETIME_TIME="$TIMESTAMP_RFC3339"
	export XZ_OPT="--check=crc64"

#	export TAR_OPTIONS="--mtime $TIMESTAMP_RFC3339 --sort-input --owner root --group root --numeric-owner" # tip: spaces in args values NOT allowed unless escaped
# ^--- tar options will be implemented as local wrapper script

	echo " * Using flavour=$flavour"
	echo " * Using use_config_from=$use_config_from"
	echo " * Using CONCURRENCY_LEVEL=$CONCURRENCY_LEVEL"
	echo " * Using PATH=$PATH"
	echo " * Using overlay_dir=$overlay_dir"
	echo " * Using FAKETIME_TIME=$FAKETIME_TIME"
	echo " * Using DEB_BUILD_TIMESTAMP=$DEB_BUILD_TIMESTAMP"
	echo " * Using TIMESTAMP_RFC3339=$TIMESTAMP_RFC3339"
	echo " * Using $tools_dpkg_which with version $tools_dpkg_ver (mempo version $tools_dpkg_vermempo)"
	echo " * Using XZ_OPT=$XZ_OPT" 
	echo " * Using MEMPO_RAND_SEED_FILE=$MEMPO_RAND_SEED_FILE"
	echo " * Using MEMPO_RAND_SEED_SEED=$MEMPO_RAND_SEED_SEED"
	# TODO | tee -a $MEMPO_BUILD_LOG   

	echo ""
	# Where to find Dpkg/Util.pm perl module:
	
	set -x
	# kernel_debug  kernel_doc kernel_manual
	faketime "$TIMESTAMP_RFC3339"	nice -n "$BUILD_NICENESS" time make-kpkg --rootcmd fakeroot kernel_image kernel_headers --initrd --revision "$DEBIAN_REVISION" --overlay-dir "$overlay_dir" 2>&1 | tee ../buildlog/build.result
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
