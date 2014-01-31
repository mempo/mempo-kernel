#!/bin/bash 
# On deterministic-kernel

# set -x 
mkdir -p kernel-sources/kernel

. kernel-build/linux-mempo/env.sh

kernel_version="$kernel_general_version" # from env.sh
kernel_file="linux-${kernel_version}.tar"
kernel_file_download="${kernel_file}.xz" # the compressed for download version of file
user_download_folder="${HOME}/Downloads/" # where user stores downloads, use this as download cache (read it, write ther)

export LC_ALL="C"

echo "Tools: checking prerequisites..."
DPKG_VER=$(dpkg-query -W --showformat='${Version}\n' dpkg)
DPKG_VER_NEEDED="1.17.5"

function show_dpkg_why {
	echo "We need dpkg version that packs files in same way, see http://tinyurl.com/pcrrvag and https://wiki.debian.org/ReproducibleBuildsKernel"
}

function show_mempo_contact {
	echo "~~ Problems, questions, suggestions or will to help us? ~~ Contact Mempo at IRC" 
	echo "IRC channel #mempo on irc.oftc.net (tor allowed), irc2p (i2p2.de then localhost 6668) or irc.freenode.org."
	echo "We will gladly help fellow Hackers and security researchers."
}

echo "(TODO check if packets like build-essentials etc are installed, warn if not)" # TODO

. prepare-toolchain.sh

echo "Tools: all ok, prerequisites seem fine"

echo ""

echo "Will get kernel sources (will verify checksum later - before actually using them)"

function download_wget() {
	echo "Downloading: " $@
	wget $@
}

echo "Kernel: $kernel_version"

if [ ! -r "kernel-sources/kernel/${kernel_file}" ]
then
(
	echo "Kernel sources are not ready (${kernel_file})"

	if [ ! -r "kernel-sources/kernel/${kernel_file_download}" ]
	then
		echo "Kernel sources are not downloaded to kernel-sources yet (${kernel_file_download})"
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
	
	else
		echo "Kernel sources were downloaded to kernel-sources already."
	fi

	(
		echo "Unpacking the downloaded file"
		cd "kernel-sources/kernel/" 
		file linux-${kernel_version}.tar.xz
		unxz linux-${kernel_version}.tar.xz
		chmod 755 linux-${kernel_version}.tar*
	)
)
#cd ..
fi


#cd ..

# TODO nicer way of entering the correct one / warning if more then one
cd kernel-build/linux-mempo || { echo "Can not enter build directory." ; exit 1; }
echo 
echo "Executing the build script"
echo 

echo "Will now execute ./all.sh to build the kernel."
./all.sh $@
set +x

