#!/bin/bash -e

./run-flavour "$1" "$2" "$3" || { echo "Build failed, aborting" ; exit 1; }

flavour="$1"
version=$( git describe --tags )
dir="$HOME/test/$version/$flavour/$date"
mkdir -p "$dir" 

cp -var "kernel-build/linux-mempo/*.deb"  "$dir/"

