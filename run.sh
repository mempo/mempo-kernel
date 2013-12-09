#!/bin/bash 
# On deterministic-kernel

set -x 
mkdir -p kernel-sources/kernel


echo "Will get kernel sources (will verify checksum later - before actually using them)"

if [ ! -r "kernel-sources/kernel/linux-3.2.53.tar" ]
then
(
	echo "Kernel sources are not ready."
	cd kernel-sources/kernel

	if [ ! -r "kernel-sources/kernel/linux-3.2.53.tar.xz" ]
	then
		echo "The .xz file not present - starting network download now"
		wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.53.tar.xz
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

pwd=$PWD
echo "In $pwd execute ./all.sh to build the kernel."
echo "Press ENTER to conitnue, or Ctrl-C to abort"

read _
./all.sh
set +x

