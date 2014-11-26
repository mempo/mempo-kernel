#!/bin/bash
# using rss to get newest version of gr, rsstail must be installed!

opt_stable_version="stable" # the 3.2 kernel was "stable2" untill 2014-06-23, now it's "stable". 

skip_intro=false
assume_yes=false
as_bot=false
url_base_stable="http://grsecurity.net/stable/" # this remains for both stable2 and stable

function help() {
	echo "Help and usage:"
	echo "This script increases kernel version in Mempo project git hub - to be used by developers"
	echo "Read all about the project on mempo.org (and mempo.i2p) or ask us on irc #mempo on irc.oftc.net"
	echo "Options:"
	echo "  -B use when you run this from build Bot, implies -A"
	echo "  -A Automatic build, e.g. for build bot, sets the needed options like -s -y"
	echo "  -s Skips introduction and pauses"
	echo "  -y assume Yes in normal questions"
	echo ""
}

while getopts "hABsy" opt; do
  case $opt in
    h)
			help
			exit 1
      ;&
    B)
      echo "running as bot" >&2
			as_bot=true
			;&
    A)
      echo "using automatic mode" >&2
			skip_intro=true
			assume_yes=true
      ;&
    s)
			skip_intro=true
      ;&
    y)
			assume_yes=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG script will exit. Use option -h to see help." >&2
			exit 100
      ;;
  esac
done

commit_msg_extra1=''
commit_msg_extra2=''
if [[ "$as_bot" == true ]]; then commit_msg_extra1='[bot]'; commit_msg_extra2=$'\n\n[bot] - commit done by automatic bot' ; fi

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


function download() { 
	echo "Downloading $new_grec from $url " 
	set -x  
	cd $gr_path ; rm changelog-${opt_stable_version}.txt 
	wget  http://grsecurity.net/changelog-${opt_stable_version}.txt  $url $url.sig 
	sha256=$(sha256deep  -q  $new_grsec)  ;  cd ../..
	set +x
} 

#all line gr in sourcecode.list
function sources_list() { 
	thefile=sourcecode.list
	echo "Updating $thefile"
	cd kernel-build/linux-mempo/
	# echo "Debug in sources_list, new_grsec=$new_grsec" 1>&2
	# exit ;
	all=P,x,x,grsecurity,$new_grsec,sha256,$sha256,./tmp-path/  
	all2=$(echo $all | sed -e 's/\ //g')
	echo $all2
	file="$(thefile)"
	tmp="$(thefile).tmp"
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

echo "Loading (current/old) env data"
source kernel-build/linux-mempo/env-data.sh


echo "Checking new version of grsecurity from network"
new_grsec=$(rsstail -u http://grsecurity.net/${opt_stable_version}_rss.php -1 | awk  '{print $2}')
url="${url_base_stable}${new_grsec}"
gr_path='kernel-sources/grsecurity/'
echo "new_grsec=$new_grsec is the current version"
kernel_ver=$( printf '%s\n' "$new_grsec" | sed -e 's/grsecurity-3.0-\(3\.[0-9]*\.[0-9]*\).*patch/\1/g' )

# echo 'grsecurity-3.0-3.2.58-201405112002.patch' | sed -e 's/grsecurity-3.0-\(3\.2\.[0-9]*\).*patch/\1/g'
echo "kernel_ver=${kernel_ver} from new (online) grsecurity version"

if [[ "$kernel_ver" != "$kernel_general_version" ]] ; then
	echo "The version of kernel from new (online) grsecurity version differs from the version for which this SameKernel was yet configured."
	echo "You need to manually increase the (vanilla) KERNEL VERSION following instructions from the readme file."
	echo "Commit version for next kernel, and then run this script again."
	echo ""
	ver_a=$kernel_general_version
	ver_b=$kernel_ver
	file_env="kernel-build/linux-mempo/env-data.sh"
	file_source="kernel-build/linux-mempo/sourcecode.list"

	# TODO do the below automatically (after informing what will be done)
	echo "Bad kernel version $kernel_general_version vs $kernel_ver from $new_grsec" >&2 
	echo "To do this, for example you can take such steps:"
	echo ""
	echo "  1) in $file_source change $ver_a to $ver_b (leave the checksum or edit it rigth away)"
	echo "  2) in $file_env change $var_a to $var_b"
	echo "  3) start build with ./run.sh - it will stop after complaining about wrong checksum, write the actuall checksum into $file_source if you didn't previously"
	echo "  3b) double check the checksum (e.g. various ISP connections etc)"
	echo ""
	
	exit 101
fi
echo "Main kernel version is OK"

. devel-update-revision.sh "restart" "batch" || { echo "Can not update revision"; exit 2; }

echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

#mywait

echo "[AUTO] I will download new grsec (to kernel-sources/grsecurity/) and I will update sources.list" ; mywait_d ;
download
sources_list

echo "-------------"
echo "[CHECK] Now we will check the GPG signature on grsecurity:"
gpg --verify $gr_path/$new_grsec.sig || { echo "Invalid signature! If you're developer of this kernel-packaging (e.g. of Mempo or Debian kernel) then tripple-check what is going on, this is very strange!" ; exit 1 ; }
echo "Press ENTER to continue if all is OK with signature (ctrl-c to abort)"
read _

echo "Commiting the new grsec ($new_grsec) files to git in one commit:"
git add $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-${opt_stable_version}.txt # XXX
git_msg="[grsec] $new_grsec ${commit_msg_extra1}${commit_msg_extra2}"
git commit $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-${opt_stable_version}.txt -m "$git_msg"

echo "Added to grsec as:"
git log HEAD^1..HEAD
mywait



echo "Now we will increase mempo version"
mywait

# . devel-update-version.sh "$@" 

echo ""
echo ""
echo "Change date and seed (from -6 block on bitcoin)" ; mywait_e
# vim kernel-build/linux-mempo/env-data.sh 

# TODO: find out next mempo version

echo ""
echo ""
cat changelog  | grep -B 1 -A 4 linux-image | head -n 4
echo "Update version CONFIG_LOCALVERSION to mempo version" ; mywait_e
# TODO: find update version name in .config
vim kernel-build/linux-mempo/configs/config-*.config 
grep "CONFIG_LOCALVERSION" kernel-build/linux-mempo/configs/config-*.config
echo "^------------- DOES THIS LOOK OK, this are the versions from config file. (edit them now in other window if not correct and press ENTER when done)"
read _


# TODO generate new block for new mempo version,
# TODO ...and put there new grsecurity info
vim changelog

#       modified:   changelog
#       #       modified:   devel-update-grsec.sh
#       #       modified:   kernel-build/linux-mempo/configs/config-desk.config
#       #       modified:   kernel-build/linux-mempo/env-data.sh
#       #       modified:   kernel-build/linux-mempo/sourcecode.list
#

# TODO commit
# TODO tag -s 
# TODO git push


echo ; echo "REMEMBER to also EDIT THE changelog file before commiting!" ; echo

echo "Now I will run sanity checks, ok?"
mywait

bash devel-check-sanity.sh || { echo "It seems sanity checks failed? I will exit then." ; exit 102; }

echo "Ok that is all. Thanks. "
mywait









