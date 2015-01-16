#!/bin/bash -e
# For use of developers
# (and called to re-check before build)
# This script does some sanity checks on some of the data
# Usage:
# devel-check-sanity.sh [batch at pos1]
# * argument 1 can be "batch" then script works more as not-interactive one

source 'support.sh' || { echo "Can not load lib" ; exit 1; }
source 'lib-sanity.sh' || { echo "Can not load lib" ; exit 1; }

echo -e "$bcolor_bold $bcolor_white $bcolor_bgrblue"
echo -e "=======================================$bcolor_eel"
echo -e "Running sanity checks$bcolor_eel"
echo -e "=======================================$bcolor_eel$bcolor_zero\n"

opt_batch="no"
if [[ "$1" == "batch" ]] ; then opt_batch="yes" ; fi

function mistake() {
		printf "\nERROR:\n%s\n" "Mistake in config: $@"
		exit_error 
}

for file_ini in kernel-build/linux-mempo/configs/deb7/*
do
		printf "%s\n" "Checking file_ini: $file_ini"
		(	
			#echo "Executing $file_ini" ; 
			source "$file_ini" || mistake "Can not read file_ini=$file_ini"

			#echo $config_localversion_name
			file_kernelconfig="kernel-build/linux-mempo/configs-kernel/$kernel_config_name"
			if [[ ! -r "$file_kernelconfig" ]] ; then echo "Can not read file_kernelconfig=$file_kernelconfig"; exit 1; fi
			config_localversion_name_from_config=$( sed -n 's/^CONFIG_LOCALVERSION="-\(.*\)\.[0-9]\+\.[0-9]\+"/\1/p' "$file_kernelconfig" )
			if [[ "$config_localversion_name_from_config" != "$config_localversion_name" ]] ; then
				mistake "The localversion_name from the config file ($file_kernelconfig) is ($config_localversion_name_from_config) and it differs from the name specified in ini file ($file_ini) that is ($config_localversion_name)"; 
			fi
		) || exit
done

print_ok_header "[OK] All ini files seems fine"

function kernel_general_version_VALIDATE() {
    # echo "TEST $1" # XXX
	if [[ "$1" =~ ^[0-9]{1}\.[0-9]{1,2}\.[0-9]{1,2}$ ]] ; then return 0 ; fi
	if [[ "$2" != "q" ]] ; then echo "Failed regexp for string: [$1]" ; fi
	return 1
}

function CURRENT_SEED_VALIDATE() {
	if [[ "$1" =~ ^[0-9a-f]{64}$ ]] ; then return 0 ; fi
	if [[ "$2" != "q" ]] ; then echo "Failed regexp for string: [$1]" ; fi
	return 1
}

function DEBIAN_REVISION_VALIDATE() {
	if [[ "$1" =~ ^[0-9]{3}$ ]] ; then 
		if [[ "$1" != "000" ]] ; then return 0 ; fi # do not use zero, start from at least value of 1
	fi
	if [[ "$2" != "q" ]] ; then echo "Failed regexp for string: [$1]" ; fi
	return 1
}

function KERNEL_DATE_VALIDATE_1() {
	if [[ "$1" =~ ^2[0-9]{3}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] ; then return 0 ; fi
	if [[ "$2" != "q" ]] ; then echo "Failed regexp for string: [$1]" ; fi
	return 1
}
function KERNEL_DATE_VALIDATE_2() {
	date -d "$1" &> /dev/null && return 0
	if [[ "$2" != "q" ]] ; then echo "Failed TEST (date) for string: [$1]" ; fi
	return 1
}

function KERNEL_DATE_VALIDATE_all() {
	KERNEL_DATE_VALIDATE_1 "$1" "$2" || return 1
	KERNEL_DATE_VALIDATE_2 "$1" "$2" || return 1
	return 0
}

function KERNEL_DATE_VALIDATE() { 
	KERNEL_DATE_VALIDATE_all "$1" "$2" && return 0
	if [[ "$2" != "q" ]] ; then echo "Failed string: [$1]" ; fi
	return 1
}

function check_envdata() {
	(
		file_envdata="kernel-build/linux-mempo/env-data.sh"
		file_env="kernel-build/linux-mempo/env.sh" # TODO for custom env-data from ini this needs to be modified
		file_env_dir=$(dirname "$file_env")
		file_envdata_dir=$(dirname "$file_envdata")
		if [[ "$file_env_dir" != "$file_envdata_dir" ]] ; then echo "ASSERT failed different directory of env/envdata." ; exit 1 ; fi
		echo "Checking file_envdata: $file_envdata"
		# cat $file_envdata
# export kernel_general_version="3.2.64" # base version (should match the one is sourcecode.list)
# export KERNEL_DATE='2014-11-26 11:53:20' # UTC time of mempo version. This is > then max(kernel,grsec,patches) times
# export CURRENT_SEED='ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852d' # litecoin block 683530 (*)
# export DEBIAN_REVISION='' # see README.md how to update it on git tag, on rc and final releases

		#echo "Executing $file_envdata" ;
		source "$file_envdata" || mistake "Can not read file_envdata=$file_envdata"

		bad_regexp_msg="The regexp self-test failed, the code of program doing the checks has a bug (also it could be bad bash version for example), PLEASE report this bug"

		kernel_general_version_VALIDATE "$kernel_general_version" || mistake "bad kernel version"
		kernel_general_version_VALIDATE "3.14.2" q || mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.1414.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.141414.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.14.2x" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.14.x2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.14x.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.x14.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "x3.14.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "314.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3.14." q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE ".14.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "3..14.2" q && mistake "$bad_regexp_msg"
		kernel_general_version_VALIDATE "" q && mistake "$bad_regexp_msg"

		KERNEL_DATE_VALIDATE "$KERNEL_DATE" || mistake "bad kernel date"
		KERNEL_DATE_VALIDATE "2014-11-26 11:53:20" || mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26 11:53:200" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26 11:53:20 " q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE " 2014-11-26 11:53:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "3014-11-26 11:53:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-111-26 11:53:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-1x-26 11:53:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26x11:53:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26 11:20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26 11::20" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-11-26 24:01:00" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "2014-13-01 12:00:00" q && mistake "$bad_regexp_msg"
		KERNEL_DATE_VALIDATE "" q && mistake "$bad_regexp_msg"

		CURRENT_SEED_VALIDATE "$CURRENT_SEED" || mistake "bad kernel seed"
		CURRENT_SEED_VALIDATE "ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852d" || mistake "$bad_regexp_msg"
		CURRENT_SEED_VALIDATE "ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852da" q && mistake "$bad_regexp_msg"
		CURRENT_SEED_VALIDATE "ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852" q && mistake "$bad_regexp_msg"
		CURRENT_SEED_VALIDATE "ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852g" q && mistake "$bad_regexp_msg"
		CURRENT_SEED_VALIDATE "ad4b6750e1d231d7c1b99f8324063482fa585cd6f71dff8b2111a4bf6063852D" q && mistake "$bad_regexp_msg"
		CURRENT_SEED_VALIDATE "" q && mistake "$bad_regexp_msg"

		DEBIAN_REVISION_VALIDATE "$DEBIAN_REVISION" || mistake "bad debian revision"
		DEBIAN_REVISION_VALIDATE "000" q && mistake "$bad_regexp_msg (zero)"
		DEBIAN_REVISION_VALIDATE "0001" q && mistake "$bad_regexp_msg (too long)"
		DEBIAN_REVISION_VALIDATE "01" q && mistake "$bad_regexp_msg (too short)"
		DEBIAN_REVISION_VALIDATE "1" q && mistake "$bad_regexp_msg (too short)"
		DEBIAN_REVISION_VALIDATE "0" q && mistake "$bad_regexp_msg (too short and zero)"
		DEBIAN_REVISION_VALIDATE "0x" q && mistake "$bad_regexp_msg (not number)"
		DEBIAN_REVISION_VALIDATE "01 " q && mistake "$bad_regexp_msg (spaces at end)"
		DEBIAN_REVISION_VALIDATE " 01" q && mistake "$bad_regexp_msg (spaces at beginning)"
		DEBIAN_REVISION_VALIDATE "" q && mistake "$bad_regexp_msg (empty)"

		#echo "Executing $file_env" ; 
		source "$file_env" "$file_envdata_dir" || mistake "Can not read file_env=$file_env"

		echo "Checking the seed:"
		echo "Seed length=$MEMPO_RAND_SEED_SEED_len"
		((MEMPO_RAND_SEED_SEED_len >= 93)) || mistake "Seed has wrong length"
		echo "LOCAL_SEED_was_used=$LOCAL_SEED_was_used"
		if [[ "$LOCAL_SEED_was_used" == "yes" ]] ; then 
			((MEMPO_RAND_SEED_SEED_len >= 93+3)) || mistake "Seed has wrong length (considering the LOCAL_SEED that you are using)"
		fi
		echo "Seed looks fine."

		echo "Done checks for file_envdata: $file_envdata"
	) || exit 1
	return 0
}

check_envdata || exit 1
print_ok_header "[OK] All envdata seems fine"

check_sourcecode_list || exit 1
print_ok_header "[OK] All source-code lists seem fine"

echo "You  HAVE TO ALSO:  Check on your own:"
echo "  * Does all kernelconfig files contain correct name version of mempo like '0.1.92' did you INCREASED it if needed? See README.md"
echo "  * Does changelog have the correct entry block for new mempo version if that was needed? See README.md"
echo "other then that, that is all."

if [[ "$opt_batch" == "no" ]] ; then
    mywait
fi



