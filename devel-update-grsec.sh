#!/bin/bash
# using rss to get newest version of gr, rsstail must be installed!

skip_intro=false
assume_yes=false
as_bot=false
url_base_stable="http://grsecurity.net/stable/"

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

echo "Loading (current/old) env data"
. kernel-build/linux-mempo/env-data.sh


echo "Checking new version of grsecurity from network"
new_grsec=$(rsstail -u http://grsecurity.net/stable2_rss.php -1 | awk  '{print $2}')
url="${url_base_stable}${new_grsec}"
gr_path='kernel-sources/grsecurity/'
echo "new_grsec=$new_grsec is the current version"
kernel_ver=$( printf '%s\n' "$new_grsec" | sed -e 's/grsecurity-3.0-\(3\.2\.[0-9]*\).*patch/\1/g' )

# echo 'grsecurity-3.0-3.2.58-201405112002.patch' | sed -e 's/grsecurity-3.0-\(3\.2\.[0-9]*\).*patch/\1/g'
echo "kernel_ver=${kernel_ver} from new (online) grsecurity version"

if [[ "$kernel_ver" != "$kernel_general_version" ]] ; then
	echo "The version of kernel from new (online) grsecurity version differs from the version for which this SameKernel was yet configured."
	echo "You need to manually increase the (vanilla) KERNEL VERSION following instructions from the readme file."
	echo "Commit version for next kernel, and then run this script again."
	echo "Bad kernel version $kernel_general_version vs $kernel_ver from $new_grsec" >&2 
	exit 101
fi
echo "Main kernel version is OK"

echo "### Preparing new env"
url_provable_entropy="http://mempo.org/random/blockchain/default/get/"
echo "Getting provable entropy from $url_provable_entropy"
entropy_data=$( wget -q "$url_provable_entropy" --output-document - ) 
entropy_seed=$( printf '%s\n' "$entropy_data" | head -n 1 | tail -n 1 )
entropy_index=$( printf '%s\n' "$entropy_data" | head -n 2 | tail -n 1 )
entropy_name=$( printf '%s\n' "$entropy_data" | head -n 3 | tail -n 1 )
echo "Got entropy seed from $entropy_name index $entropy_index:"
echo "$entropy_seed"

newenv_date=$(date +'%Y-%m-%d %H:%M:%S')
newenv_rev='01'

f_oldenv="kernel-build/linux-mempo/env-data.sh" # this will be updated
f_newenv_dir="var.update" # temp dir
mkdir -p "$f_newenv_dir"

f_newenv="$f_newenv_dir/env-data.sh"

printf '' > $f_newenv
printf '%s\n' "# place for STATIC settings for release. [autogenerated] ${commit_msg_extra1}" >> $f_newenv
printf '%s\n' "export kernel_general_version=\"$kernel_ver\" # base version (should match the one is sources.list)" >> $f_newenv
printf '%s\n' "export KERNEL_DATE='$newenv_date' # UTC time of mempo version. This is > then max(kernel,grsec,patches) times" >> $f_newenv
printf '%s\n' "export CURRENT_SEED='$entropy_seed' # $entropy_name block $entropy_index (*)" >> $f_newenv
printf '%s\n' "export DEBIAN_REVISION='$newenv_rev' # see README.md how to update it on git tag, on rc and final releases" >> $f_newenv

cp "$f_newenv" "$f_oldenv"
echo "New env is:"
cat "$f_oldenv"
echo ""

echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

#mywait

echo "[AUTO] I will download new grsec (to kernel-sources/grsecurity/) and I will update sources.list" ; mywait_d ;
download
sources_list

echo "Commiting the new grsec ($new_grsec) files to git in one commit:"
git add $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-stable2.txt # XXX
git_msg="[grsec] $new_grsec ${commit_msg_extra1}${commit_msg_extra2}"
git commit $gr_path/$new_grsec $gr_path/$new_grsec.sig $gr_path/changelog-stable2.txt -m "$git_msg"

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
vim kernel-build/linux-mempo/configs/config-desk.config 

# TODO generate new block for new mempo version,
# TODO ...and put there new grsecurity info
vim changelog

#       modified:   changelog
#       #       modified:   devel-update-grsec.sh
#       #       modified:   kernel-build/linux-mempo/configs/config-desk.config
#       #       modified:   kernel-build/linux-mempo/env-data.sh
#       #       modified:   kernel-build/linux-mempo/sources.list
#

# TODO commit
# TODO tag -s 
# TODO git push




