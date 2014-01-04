#!/bin/bash 
# On deterministic-kernel

# set -x 
mkdir -p kernel-sources/kernel


kernel_file="linux-3.2.53.tar" # the file that we want
kernel_file_download="$kernel_file.xz" # the compressed for download version of file
user_download_folder="${HOME}/Downloads/" # where user stores downloads, use this as download cache (read it, write ther)

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
		if [ ! -r "${user_download_folder}/${kernel_file_download}" ]
		then
			echo "Kernel sources are not cached in $user_download_folder"

			echo "Need .xz to download from the Internet."
			download_wget "https://www.kernel.org/pub/linux/kernel/v3.x/$kernel_file_download" -O "kernel-sources/kernel/${kernel_file_download}"

			echo "We downloaded the file from internet, and we will now save it into $user_download_folder"
			mkdir -p "${user_download_folder}/"
			cp "kernel-sources/kernel/${kernel_file_download}" "${user_download_folder}/" # cache it

		else 
			echo "Kernel sources ARE cached in $download_folder. If this file would be bad then delete it and try again to really download."
			cp "${user_download_folder}/${kernel_file_download}" "kernel-sources/kernel/$kernel_file_download" # load from cache
		fi

	fi
	(
		echo "Unpacking the downloaded file"
		cd "kernel-sources/kernel/"
		unxz linux-3.2.53.tar.xz
		chmod 755 linux-3.2.53.tar*
	)
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

cd kernel-build/linux-3.2.53-mempo-*-shell
echo 
echo "Executing the build script"
echo 

echo "Will now execute ./all.sh to build the kernel."
./all.sh $@
set +x

