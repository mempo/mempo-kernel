#!/bin/bash
# using rss to get newest version of gr, rsstail must be installed!
new_grsec=$(rsstail -u http://grsecurity.net/stable2_rss.php -1 | awk  '{print $2}')
url="http://grsecurity.net/stable/"$new_grsec
gr_path='kernel-sources/grsecurity/'

echo ""
echo "==============================================================="
echo "This script is for Mempo developers (or users wanting to hack on it)"
echo "this will take you step by step by process to upgrade Mempo for new grsecurity kernel patch"
echo "in few simple commands :) questions -> #mempo on irc.oftc.net or freenode or see mempo.org"
echo ""
echo "This is an UPDATE after grsecurity changed"
echo "Newest vesrion grsecurity is $new_grsec"
echo ""

echo " *** this script is not finished yet, you will need to do some work manually! *** "

echo "When ready press ENTER." ; read _

function mywait() {
	echo "Press ENTER when you done the above instructions"
	read _ 
}
function mywait_e() {
	echo "Press ENTER when ready, I will open editor"
	read _ 
} 
function mywait_d() {
        echo "Press ENTER to download files"
        read _ 
}
function download() { 
	echo "Downloading $new_grec from $url " 
	set -x  
	cd $gr_path ; rm changelog-stable2.txt ; wget -q  http://grsecurity.net/changelog-stable2.txt  $url $url.sig 
	sha256=$(sha256deep  -q  $new_grsec)  ;  cd ../..

	set +x
} 

#all line gr in sources.list
function sources_list() { 
	echo "Updating sources.list"
	cd kernel-build/linux-mempo/
	# echo "Debug in sources_list, new_grsec=$new_grsec" 1>&2
	# exit ;
	all=P,x,x,grsecurity,$new_grsec,sha256,$sha256,./tmp-path/  
	all2=$(echo $all | sed -e 's/\ //g')
	echo $all2
	file='sources.list'
	tmp='sources.list.tmp'
	mv $file $tmp
	let i=0
	
	for line in $(cat $tmp); do
        	let i=$i+1
		if [[ $i -eq 2 ]]       
		then    
			echo $all2 >> $file  
			echo "Line: $all2 was saved" 
        	else  
                	echo $line >> $file 
        	fi 
	done 
	rm $tmp
	cd ../..
}

echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

echo "Read README and info how to update on https://github.com/mempo/deterministic-kernel/ (or local file README.md here)" 
mywait

echo "[AUTO] Downloadng new grsec (to kernel-sources/grsecurity/) and updating sources.list" ; mywait_d ; download
sources_list
# echo ""
# ls -rtl "kernel-sources/grsecurity/"
# echo "What is the file name of new grsec .patch? (copy/type the filename and press enter)"; echo -n "> " ; read gr_patch_file
# gr_patch="kernel-sources/grsecurity/$gr_patch_file"
# echo ""

# echo "Add new textblock for new mempo version (increase with new grsec), you said grsec is $gr_patch_file" ; mywait_e
# vim changelog

# sha256sum $gr_patch || { echo "Can not checksum $gr_patch" ; exit 1; }
# echo "Copy the above CHECKSUM and FILENAME to replace both in line with grsecurity in the file..."
# mywait_e
# vim kernel-build/linux-mempo/sources.list
echo "Now we will increase mempo version"
mywait
. devel-update-version.sh

