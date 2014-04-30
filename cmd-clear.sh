#!/bin/bash
# clear build data, especially for saving free disk space

df -h . 
echo "Will clear:"
du -sh kernel-build/linux-mempo/linux-?.*.*/

sleep 1

rm -rf kernel-build/linux-mempo/linux-?.*.*/

echo "Clear, free space: "
df -h . 
