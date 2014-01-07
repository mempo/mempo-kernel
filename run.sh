#!/bin/bash 
# On deterministic-kernel

# set -x 
mkdir -p kernel-sources/kernel

kernel_version="3.2.54"
kernel_file="linux-${kernel_version}.tar"
kernel_file_download="${kernel_file}.xz" # the compressed for download version of file
user_download_folder="${HOME}/Downloads/" # where user stores downloads, use this as download cache (read it, write ther)

echo "Will get kernel sources (will verify checksum later - before actually using them)"

function download_wget() {
	echo "Downloading: " $@
	wget $@
}

if [ ! -r "kernel-sources/kernel/${kernel_file}" ]
then
(
	echo "Kernel sources are not ready (${kernel_file})"

	if [ ! -r "kernel-sources/kernel/${kernel_file_download}" ]
	then
		echo "Kernel sources are not downloaded locally yet (${kernel_file_download})"
		if [ ! -r "${user_download_folder}/${kernel_file_download}" ]
		then
			echo "Kernel sources are not cached in ${user_download_folder}"

			echo "Need .xz to download from the Internet."
			download_wget "https://www.kernel.org/pub/linux/kernel/v3.x/${kernel_file_download}" -O "kernel-sources/kernel/${kernel_file_download}"

			echo "We downloaded the file from internet, and we will now save it into ${user_download_folder}"
			mkdir -p "${user_download_folder}/"
			cp "kernel-sources/kernel/${kernel_file_download}" "${user_download_folder}/" # cache it

		else 
			echo "Kernel sources ARE cached in ${user_download_folder}. If this file would be bad then delete it and try again to really download."
			cp "${user_download_folder}/${kernel_file_download}" "kernel-sources/kernel/${kernel_file_download}" # load from cache
		fi

	fi
	(
		echo "Unpacking the downloaded file"
		cd "kernel-sources/kernel/" 
                unxz linux-${kernel_version}.tar.xz
                chmod 755 linux-${kernel_version}.tar*

	)
)
#cd ..
fi


#cd ..

# TODO nicer way of entering the correct one / warning if more then one
cd kernel-build/linux-${kernel_version}-mempo-*-shell
echo 
echo "Executing the build script"
echo 

echo "Will now execute ./all.sh to build the kernel."
./all.sh $@
set +x

