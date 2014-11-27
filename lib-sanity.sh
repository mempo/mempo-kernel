#!/bin/bash -e

# this is a bash library - only for inclusion from other scripts here
# this file is providing some functions aiding in validation and sanity checking

source "support.sh"

function check_sourcecode_list() { # warning it might change current directory in case of error
	thefile="sourcecode.list" # TODO make this depend on choosen ini file

	(
	cd kernel-build/linux-mempo/ # working here
	echo "Validating sourcecode list in ($thefile) in pwd ($PWD)"

	# test the resulting file for sanity
	
# V,ID_kernel_vanilla_ID,x,kernel,linux-3.2.64.tar,sha256,d49248b2a99a5dc5b2fae001c177bec849bce1786d31363bbb5849ac32dcc602,./
# P,ID_grsecurity_main_ID,x,grsecurity,grsecurity-3.0-3.2.64-201411091051.patch,sha256,9820e85fc3f83d7464f7192d916953dd940fc2f912a4ba2ef457bf4090ecfaaf,./tmp-path/
# P,ID_mempo_grsec_ID,x,mempo,grsecurity-3.0-3.2.55-201402152203-mempo-extra.patch,sha256,a8e81062e44ea899af688a326aaebcfd86d759da69b39f6ed66b7a8e7bcf9a8d,./tmp-path/
# P,ID_mempo_determ_ID,x,mempo,linux-3.2.57-grsec-deterministic-build.patch,sha256,aca4001855c4c822c78aee90acc8706a3ffb3b5e4d42f07b4ffe827190d77d59,./tmp-path/

	# test for all the mandatory sections
	# this will be tuned later for ini that e.g. have just vanilla kernel and/or ini will list exactly which tags it wishes to use
	for tag in 'ID_kernel_vanilla_ID' 'ID_grsecurity_main_ID'
	do
		(
			tag='ID_kernel_vanilla_ID';
			match_cnt=$( grep "$tag" "$thefile" | wc -l )
			if [[ "$match_cnt" != "1" ]] ; then
					echo "@@@ ERROR ! @@@" ; echo "File ($thefile) had wrong count of tag ($tag)"
					exit 1
			fi
		) || exit 1
	done

	# additional test for ID_grsecurity_main_ID 
	(
		match2="no"
		grep 'ID_grsecurity_main_ID' "$thefile" > /dev/null && match2="yes"
		match_cnt=$( grep 'ID_grsecurity_main_ID' "$thefile" | wc -l )
		if [[ "$match2" != "yes" ]] ; then
				echo "@@@ ERROR IN THE SCRIPT ! @@@" ; echo "At checking again: The sources list file ($thefile) had unexpected format (see sources for details) !"
				echo "Press ctrl-c to exit and FIX THIS PROBLEM" ; read _  echo "abort." ; exit 1;
		fi
		if [[ "$match_cnt" != "1" ]] ; then
				echo "@@@ ERROR IN THE SCRIPT ! @@@" ; echo "At checking the count: The sources list file ($thefile) had unexpected format (see sources for details) !"
				echo "Press ctrl-c to exit and FIX THIS PROBLEM" ; read _  echo "abort." ; exit 1;
		fi
	) || exit 1



	) || exit 1

	echo "File $thefile seems to passed basic tests"
	return 0
}

# check_sourcecode_list 

