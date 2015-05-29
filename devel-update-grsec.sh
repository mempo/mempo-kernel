#!/bin/bash -e
# using rss to get newest version of gr, rsstail must be installed!

source 'support.sh' || { echo "Can not load lib" ; exit 1; }
source 'lib-ifccs_00004.sh' || { echo "Can not load lib lib-ifccs_00004.sh" ; exit 1; }

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
echo "Mempo Devel: Update Grsecurity"
echo "==============================================================="
echo "This script is for Mempo developers (or users wanting to hack on it)"
echo "this will take you step by step by process to upgrade Mempo for new grsecurity kernel patch"
echo "in few simple commands :) questions -> #mempo on irc.oftc.net or freenode or see mempo.org"
echo ""
echo "This is an UPDATE after grsecurity changed"
echo "Newest version of grsecurity is: $new_grsec"
echo ""

echo " *** this script is NOT 100% automated YET - so you will need to do some work manually! *** "
echo "Read README and info how to update on https://github.com/mempo/deterministic-kernel/ (or local file README.md here)" 
mywait


function download() { 
	echo "Downloading $new_grec from $url " 
	set -x  
	cd $gr_path ; rm changelog-${opt_stable_version}.txt 

	# TODO detect if we are re-downloading same file again, if that link redirects to a file name that we already have 
	# for the kernel/sig and then report a bug that this is the same version so no need for upgrade
	wget  http://grsecurity.net/changelog-${opt_stable_version}.txt  $url $url.sig 
	sha256=$(sha256deep  -q  $new_grsec)  ;  cd ../..
	set +x
} 

#all line gr in sourcecode.list
function sources_list() { 
	pwd=$PWD
	cd "kernel-build/linux-mempo/" || { echo "ERROR: can not chang working directory" ; exit 1; } # working here
	thefile="sourcecode.list" # TODO make this depend on choosen ini file
	echo "Updating $thefile"
	# echo "Debug in sources_list, new_grsec=$new_grsec" 1>&2
	# exit ;
	all="P,ID_grsecurity_main_ID,x,grsecurity,$new_grsec,sha256,$sha256,./tmp-path/"
	all2=$(echo $all | sed -e 's/\ //g')
	echo "Will add line: ($all2)"

	file="$thefile"
	tmp="$thefile.tmp"
	mv "$file" "$tmp" || { echo "ERROR: Can not move file ($file) to tmp ($tmp)"; exit 1; }

	let i=0
	# format of this file, is that it must have exactly *one* line with tag *ID_grsecurity_main_ID* , the line *number 2*
	for line in $(cat $tmp); do
		let i=$i+1
		if [[ $i -eq 2 ]]
		then    
			match="no"
			echo "$line" | grep 'ID_grsecurity_main_ID' && match="yes"
			if [[ "$match" != "yes" ]] ; then
					echo "@@@ ERROR IN THE SCRIPT ! @@@"
					echo "The sources list file ($thefile) had unexpected format i=($i) line=($line) (see sources for details) !"
					echo "Press ctrl-c to exit and FIX THIS PROBLEM" ; read _ 
					echo "abort." ; exit 1;
			fi
			echo $all2 >> $file  
			echo "Line: $all2 was saved" 
     	else  
    	 	echo $line >> $file 
      fi 
	done 

	# more tests will be done as part of sanity checks later

	rm $tmp
	cd $pwd # back to correct dir
}

echo "Loading (current/old) env data"
source kernel-build/linux-mempo/env-data.sh
echo "kernel_general_version=$kernel_general_version"

echo "Checking new version of grsecurity from network"
new_grsec=$(rsstail -u http://grsecurity.net/${opt_stable_version}_rss.php -1 | awk  '{print $2}')
echo "new_grsec=$new_grsec"
url="${url_base_stable}${new_grsec}"
gr_path='kernel-sources/grsecurity/'
echo "new_grsec=$new_grsec is the current version"

kernel_ver=$( printf '%s\n' "$new_grsec" | sed -e 's/grsecurity-3.1-\(3\.[0-9]*\.[0-9]*\).*patch/\1/g' )

# echo 'grsecurity-3.0-3.2.58-201405112002.patch' | sed -e 's/grsecurity-3.0-\(3\.2\.[0-9]*\).*patch/\1/g'
echo "kernel_ver=${kernel_ver} as autodetected from new (online) grsecurity version"

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
	echo "  2) in $file_env change $ver_a to $ver_b"
	echo "  3) start build with ./run.sh - it will stop after complaining about wrong checksum, write the actuall checksum into $file_source if you didn't previously"
	echo "  3b) double check the checksum (e.g. various ISP connections etc)"
	echo ""
	
	exit 101
fi


print_ok_header "Main kernel version is OK"


function update_kernel_version {
	for kconfig in kernel-build/linux-mempo/configs-kernel/*.kernel-config 
	do
		echo
		temp=$( mktemp -t "kconfXXXXXX" )
		echo "Updating: $kconfig with temp=$temp"
		cat "$kconfig" | gawk 'BEGIN{ FS="="  } $1=="CONFIG_LOCALVERSION" { match($2,/"(-mempo)\.([^.]+)\.([[:digit:]]+)\.([[:digit:]]+)\.([[:digit:]]+)"/,a) ; print $1 "=" "\"" a[1] "." a[2] "." a[3] "." a[4] "." (a[5]+1) "\"" ; next } { print $0 } ' > "$temp"
		echo "Diff:"
		diff -Nuar "$kconfig" "$temp" || { : ; } # why diff is non-zero exit?
		cp -v "$temp" "$kconfig"
		rm "$temp"
	done
	echo "Loop done"
}

echo "Updating kernel version"
update_kernel_version

echo "The version CONFIG_LOCALVERSION was automatically updated." ; mywait_e
# TODO: find update version name in .config
vim kernel-build/linux-mempo/configs-kernel/*.kernel-config
grep "CONFIG_LOCALVERSION" kernel-build/linux-mempo/configs-kernel/*.kernel-config
echo "^------------- DOES THIS LOOK OK, this are the versions from config file. (edit them now in other window if not correct and press ENTER when done)"
read _

bash devel-update-revision.sh "restart" "batch" || { echo "Can not update revision"; exit 2; }


echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

#mywait

echo "[AUTO] GIT: remove all old patches first"
git rm "$gr_path/*.patch" ""$gr_path/*.patch.sig || { 
	start_quit_dev
	echo "Strange, there are no old patches to git remove. If you do not know what is going on, git checkout and start over"; 
	echo "View of the directory gr_path=$gr_path is:"
	ls -l "$gr_path"
	ask_quit_dev
}

echo "[AUTO] I will download new grsec (to kernel-sources/grsecurity/) and I will update sources.list" ; mywait_d ;
download || { echo "ERROR: Download failed" ; exit 1; }
sources_list || { echo "ERROR: Sources list update failed" ; exit 2; }

echo "-------------"
echo "[CHECK] Now we will check the GPG signature on grsecurity:"
gpg --verify $gr_path/$new_grsec.sig || { echo "Invalid signature! If you're developer of this kernel-packaging (e.g. of Mempo or Debian kernel) then tripple-check what is going on, this is very strange!" ; exit 1 ; }
echo "Press ENTER to continue if all is OK with signature (ctrl-c to abort)"
mywait

echo "Commiting the new grsec ($new_grsec) files to git in one commit:"
git add $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-${opt_stable_version}.txt || {
	start_quit_dev
	echo "No new files (grsecurity patches?) were added now (git already had them)" 
	echo "Are you sure this is OK? That should not happen if you are really now downloading new grsecurity ! @@@"
	echo "Are you sure there is new released (of that grsecurity version that we use, e.g. stable or stable2)?"
	ask_quit_dev
}

git_msg="[grsec] $new_grsec ${commit_msg_extra1}${commit_msg_extra2}"
echo "[AUTO] GIT: message to COMMIT now the new files (patches) is: $git_msg"
git commit $gr_path/ $gr_path/* -m "$git_msg" || {
	start_quit_dev
	echo "The git commit failed. Maybe you do not have network or you did not set git remote set-url etc."
	echo "You still should do a git commit with message: $git_msg"
	echo "You can do the commit now in other console and continue here."
	ask_quit_dev
}

echo "Added to grsec as:"
git log HEAD^1..HEAD
mywait



echo "Now we will increase mempo version"
mywait

# . devel-update-version.sh "$@" 

#echo ""
#echo ""
#echo "Change date and seed (from -6 block on bitcoin)" ; mywait_e
# vim kernel-build/linux-mempo/env-data.sh 

# TODO: find out next mempo version

echo ""
echo ""
cat changelog  | grep -B 1 -A 4 linux-image | head -n 4
mywait

echo "Now I will show you what was changed and now commited from grsec."
echo "Write down a summary to add to our changelog based on the diff with grsec changelog:"
mywait

git show HEAD || { echo "Error in git show? Ignoring." }

echo "Now opening editor. Remember to change the DATE and VERSION OF MEMPO there"
mywait


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



echo "Now I will run sanity checks, ok?"
mywait

bash devel-check-sanity.sh || { echo "It seems sanity checks failed? I will exit then." ; exit 102; }
echo "Ok that is all. Thanks."
# echo ; echo "also, REMEMBER to also EDIT THE changelog file before commiting!" ; echo
mywait

