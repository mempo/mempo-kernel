#!/bin/bash 
# On deterministic-kernel

set -x 
mkdir -p kernel-sources/kernel


kernel_file="linux-3.2.53.tar"
kernel_file_download="$kernel_file.xz"

echo "Will get kernel sources (will verify checksum later - before actually using them)"

function download_wget() {
	echo "Downloading: " $@
	wget $@
}

if [ ! -r "kernel-sources/kernel/$kernel_file" ]
then
(
	echo "Kernel sources are not ready ($kernel_file)"

	if [ ! -r "kernel-sources/kernel/$kernel_file_download" ]
	then
		echo "Kernel sources are not downloaded locally yet ($kernel_file_download)"
		download_folder="${HOME}/Downloads/"
		if [ ! -r "${download_folder}/${kernel_file_download}" ]
		then
			echo "Kernel sources are not cached in $download_folder"

			echo "Need .xz to download from the Internet."
			download_wget "https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.53.tar.xz"
		else 
			echo "Kernel sources ARE cached in $download_folder. If this file would be bad then delete it and try again to really download."
			cp "${download_folder}/${kernel_file_download}" "kernel-sources/kernel/$kernel_file_download" 
		fi

	fi
	wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.53.tar.sign
	unxz linux-3.2.53.tar.xz
	chmod 755 linux-3.2.53.tar*
)
#cd ..
fi


(
echo "Grsecurity"
#mkdir -p grsecurity
#cd grsecurity
#wget http://grsecurity.net/stable/grsecurity-3.0-3.2.53-201312021727.patch
#wget http://grsecurity.net/stable/grsecurity-3.0-3.2.53-201312021727.patch.sig
#chmod 755 grsecurity-3.0-3.2.53-201312021727.patch*
#cd ..
)

#cd ..

#deterministic-kernel

cd kernel-build/linux-3.2.53-mempo-0.1.16-shell
echo 
echo "Executing the build script"
echo 
#faketime "2013-12-02 17:28:00" ./all.sh  # time is set not here, but in env.sh

echo "Will now execute ./all.sh to build the kernel."

./all.sh
set +x

