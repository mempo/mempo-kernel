#!/bin/bash
# path to linux kernel
# example: ./gz_unpack.sh $HOME/ready/3.2.52/1/linux-3.2.52/ $HOME/ready/3.2.52/2/linux-3.2.52/
dir1=$1
dir2=$2
doc_dir=$HOME/gz_files

set -x
# create directory
mkdir -p $doc_dir
mkdir -p $doc_dir/1
mkdir -p $doc_dir/2

# create list of all .gz files
cd $dir1
find -name *.gz > $doc_dir/gzfilelist.txt

# copy .gz files to ~/gz_files
exec 3<$doc_dir/gzfilelist.txt
while read line  
do
        echo -e "$line \n" 
        cd $dir1
        cp $line  $doc_dir/1

        cd $dir2
        cp $line $doc_dir/2
done <&3

# unpack file 
cd $doc_dir/1
gunzip *
sha512sum * | sort > ../checksums1.txt

cd $doc_dir/2
gunzip *
sha512sum * | sort > ../checksums2.txt



set +x

