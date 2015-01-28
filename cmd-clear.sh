#!/bin/bash
# clear build data, especially for saving free disk space

df -h . 
echo ; echo "Will clear also:"
du -sh kernel-build/linux-mempo/linux-?.*.*/

rm -rf kernel-build/linux-mempo/linux-?.*.*/

echo ; echo "Clearing also other dirs, logs, ..."
set -x
rm -rfv kernel-build/linux-mempo/buildlog/
rm -rfv kernel-build/linux-mempo/tmp-path/
set +x

echo ; echo "Clear, free space: "
df -h . 
