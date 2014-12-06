#!/bin/bash
# This is a library for bash, do not run it - it will be just included by other scripts
# From http://mywiki.wooledge.org/BashFAQ/037
#
# This are messages for support etc

source "$(dirname $BASH_SOURCE)/bashcolors.sh" || { echo 'Can not load bashcolors.sh' ; exit 1 ; }

function show_support_info {
	echo "**************************************************"
	echo -e "${bcolor_yellow}${bcolor_bgrblack}It seems there was some problem, as written above?${bcolor_zero}"
	echo ""
	echo "SUPPORT: for help, see https://wiki.debian.org/Mempo#contact"
	echo "check for common errors here: read FAQ: https://wiki.debian.org/SameKernel/#FAQ"
	echo "LOCAL-COPY of part of help pages, doc and FAQ is located here in directory doc-mirror/ !"
	echo "See #mempo on irc.oftc.net or freenode or irc2p - ask question, wait up to 24 hours, we will reply!"
	echo "also freenet on FMS boards: linux or mempo (remember to solve captchas) we reply in 1-3 days."
	echo "also http://mempo.org"
	echo "( write down all entire messages, last 20-50 lines of text, this will help to solve your issue )"
}

function exit_error() {
	msg="$1" # can be empty argument, then you should had outputed the error message yourself before calling
	if [[ -n "$msg" ]] ; then
		echo -e "${bcolor_bgrblack}${bcolor_red}ERROR: $msg${bcolor_zero}"
	fi
	show_support_info
	echo -e "${bcolor_bgrblack}${bcolor_red}Aborting.${bcolor_zero}"
	exit 1
}

function	start_quit_dev() {
	echo ""
	echo "***************************************************************************************"
	echo -e "${bcolor_bgrblack}${bcolor_red}Warning, for Developer!${bcolor_zero}"
}

function ask_quit_dev() {
	echo "***************************************************************************************"
	echo "Read carefully error/warning for DEVELOPER."
	echo -e "${bcolor_bgrblack}${bcolor_red}If you are sure all is fine the enter, in uppercase, the word YES${bcolor_zero}"
	echo "otherwise we will abort"
	read yn
	if [[ $yn == "YES" ]] ; then 
		echo "Ok, ignoring this."
	else exit_error ; exit 1 ; fi
}

function ask_quit() {
	kind=$1
	if [[ $kind == "nosum" ]] ; then
		:
	else
		echo "***************************************************************************************"
		echo -e "${bcolor_bgrblack}${bcolor_yellow}!!! Due to above-mentioned problems, this script will probably not work, e.g. produce other checksums${bcolor_zero}"
		echo "***************************************************************************************"
	fi

	echo "*** Help: read FAQ: https://wiki.debian.org/SameKernel/#FAQ (and local copy in doc-mirror/)"
	echo "Do you want to ignore this problem and try to continue anyway? y/N?"
	read yn
	if [[ $yn == "y" ]] ; then 
		echo ; 
		if [[ $kind == "nosum" ]] ; then
			echo "*** ignoring this problem ***" ; 
		else
			echo "*** ignoring this problem - !!! IT WILL LIKELLY PRODUCE DIFFERENT CHECKSUMS THEN EXPECTED !!! ***" ; 
		fi
		echo ; 
	else exit_error ; fi
}


function mywait() {
	if [[ "$skip_intro" == true ]]; then return; fi
	echo "${bcolor_bgrblack}${bcolor_blue}Press ENTER when you done with the above instructions${bcolor_zero}"
	read _ 
}
function mywait_e() {
	if [[ "$skip_intro" == true ]]; then return; fi
	echo "${bcolor_bgrblack}${bcolor_blue}Press ENTER when ready, ${bcolor_bold}I will open editor${bcolor_zero}"
	read _ 
} 
function mywait_d() {
	if [[ "$skip_intro" == true ]]; then return; fi
	echo "${bcolor_bgrblack}${bcolor_blue}Press ENTER${bcolor_zero} when ready to ${bcolor_bgrblack}${bcolor_red}download files from Internet${bcolor_zero} (the download will be probably NOT anonymous unless stated otherwise or if you took special steps e.g. are running from Tor)"
	read _ 
}
