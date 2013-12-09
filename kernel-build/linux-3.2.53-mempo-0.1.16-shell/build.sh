#!/bin/bash -e
# do NOT run this directly, run build-run.sh

linuxdir="$1"
if [ -z "$linuxdir" ] ; then
	echo "ERROR undefined linuxdir." ; exit 1
fi

echo "Building linuxdir=$linuxdir"

echo "Creating sources info"
bash /home/kernelbuild/make-source-info

echo "Loading env"
. env.sh
export CONCURRENCY_LEVEL=8 
export BUILD_NICENESS=0

echo "Starting build in $linuxdir"

(
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



	echo ""
	echo "=== BUILD MAIN ================================="
	nice -n "$BUILD_NICENESS" time make-kpkg --rootcmd fakeroot kernel_image kernel_headers kernel_debug  kernel_doc kernel_manual  --initrd --revision "$DEBIAN_REVISION" 2>1 | tee ../buildlog/build.result
	echo "... returned from the main BUILD program"
	echo
	date
	echo "================================================"
)

echo 
echo "Done building in $linuxdir"
