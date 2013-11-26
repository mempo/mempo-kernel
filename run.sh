#!/bin/bash 

set -x 
# download kernel
mkdir -p kernel-sources/kernel 
cd kernel-sources/kernel
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.51.tar.xz  
# unpack kernel
unxz linux-3.2.51.tar.xz
wget https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.51.tar.sig
# run complilation
cd ../../kernel-build/linux-3.2.51-securian-0.1.9-shell 
faketime "2013-10-19 12:58:00" ./all.sh
set +x
