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

	echo "File $thefile seems to passed basic tests"
	return 0
}

# check_sourcecode_list 

