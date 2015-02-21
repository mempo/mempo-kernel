#!/bin/bash -e
# run proper make oldconfig on all configs to update them

source 'support.sh' || { echo "Can not load lib" ; exit 1; }
source 'lib-ifccs_00004.sh' || { echo "Can not load lib lib-ifccs_00004.sh" ; exit 1; }

echo "* You must have prepared kernel-build/linux-mempo/linux-x.y.z with current kernel"
echo "e.g. do ./run.sh and stop it after a while (ctrl-c)" # TODO
echo "(we assume this is done)" # TODO
echo "TODO: also, this assumes same kernel+patches (do it on grsec version)"
echo "...we do not support here e.g. vanilla version too good (it will contain garbage CONFIG options and not recaulcated config deps)"
echo "Press ENTER..." ; echo ok

cd kernel-build/linux-mempo/linux-*.*.*/ # TODO nicer
pwd

for kernel in ../configs-kernel/*.kernel-config
do
	echo "Working on $kernel"
	rm .config
	cp $kernel .config
	make oldconfig
	rm $kernel
	cp .config $kernel
	git diff $kernel
done

# kernelbuild@tesla:~/deterministic-kernel/kernel-build/linux-mempo/linux-3.2.67$ # cp ../configs-kernel/deb7-deskmaxdbg.kernel-config  .config

