#!/bin/bash -e
FLAVOUr="$1"
version=$( git describe --tags )
date=$( date -u +%s )
computer=$HOSTNAME

date_start=$( date -u +%s )

bash ./run-flavour.sh "$1" "$2" "$3" || { echo "Build failed, aborting" ; exit 1; }

date_done=$( date -u +%s )

seconds=$(( date_done - date_start ))

pwd=$PWD
cd kernel-build/linux-mempo
sums_eol="$(sha1sum *.deb )"
sums="$(echo $sums_eol)" # flatten it into one line with no /n
cd $pwd

echo 
echo "Build $flavour ver $version on $computer in $seconds sec, Sums: $sums" | tee -a ~/result.txt
echo 

dir="$HOME/test/$version/$flavour/$date"
echo "Dir is: $dir"
mkdir -p "$dir" 
cp -var kernel-build/linux-mempo/*.deb  "$dir/"

