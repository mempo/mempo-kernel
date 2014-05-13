#!/bin/bash
# using rss to get newest version of gr, rsstail must be installed!

skip_intro=false
assume_yes=false

url_base_stable="http://grsecurity.net/stable/"

function help() {
	echo "Help and usage:"
	echo "This script increases kernel version in Mempo project git hub - to be used by developers"
	echo "Read all about the project on mempo.org (and mempo.i2p) or ask us on irc #mempo on irc.oftc.net"
	echo "Options:"
	echo "  -A Automatic build, e.g. for build bot, sets the needed options like -s -y"
	echo "  -s Skips introduction and pauses"
	echo "  -y assume Yes in normal questions"
	echo ""
}

while getopts "hAsy" opt; do
  case $opt in
    h)
			help
			exit 1
      ;;
    A)
      echo "using automatic mode" >&2
			skip_intro=true
			assume_yes=true
      ;;
    s)
			skip_intro=true
      ;;
    y)
			assume_yes=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG script will exit. Use option -h to see help." >&2
			exit 100
      ;;
  esac
done


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
echo "Read README and info how to update on https://github.com/mempo/deterministic-kernel/ (or local file README.md here)" 

function mywait() {
	if [[ "$skip_intro" == true ]]; then return; fi
	echo "Press ENTER when you done the above instructions"
	read _ 
}
function mywait_e() {
	if [[ "$skip_intro" == true ]]; then return; fi
	echo "Press ENTER when ready, I will open editor"
	read _ 
} 
function mywait_d() {
	if [[ "$skip_intro" == true ]]; then return; fi
			echo "Press ENTER to download files"
			read _ 
}

function download() { 
	echo "Downloading $new_grec from $url " 
	set -x  
	cd $gr_path ; rm changelog-stable2.txt 
	wget  http://grsecurity.net/changelog-stable2.txt  $url $url.sig 
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

echo "Checking new version of grsecurity from network"
new_grsec=$(rsstail -u http://grsecurity.net/stable2_rss.php -1 | awk  '{print $2}')
url="${url_base_stable}${new_grsec}"
gr_path='kernel-sources/grsecurity/'
echo "new_grsec=$new_grsec is the current version"

echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

#mywait

echo "[AUTO] I will download new grsec (to kernel-sources/grsecurity/) and I will update sources.list" ; mywait_d ;
download
sources_list

echo "Commiting the new grsec ($new_grsec) files to git in one commit:"
git add $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-stable2.txt
git commit $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-stable2.txt -m "[grsec]auto $new_grsec"

echo "Added to grsec as:"
git log HEAD^1..HEAD
mywait



echo "Now we will increase mempo version"
mywait
. devel-update-version.sh

