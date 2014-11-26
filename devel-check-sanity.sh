#!/bin/bash

source "support.sh"

echo "======================================="
echo "Running sanity checks"
echo "======================================="

function mistake() {
		printf "\nERROR:\n%s\n" "Mistake in config: $@"
		exit_error 
}

for file_ini in kernel-build/linux-mempo/configs/deb7/*
do
		printf "%s\n" "Checking file_ini: $file_ini"
		(	
			source "$file_ini" || mistake "Can not read file_ini=$file_ini"
			#echo $config_localversion_name
			file_kernelconfig="kernel-build/linux-mempo/configs-kernel/$kernel_config_name"
			if [[ ! -r "$file_kernelconfig" ]] ; then echo "Can not read file_kernelconfig=$file_kernelconfig"; exit 1; fi
			config_localversion_name_from_config=$( sed -n 's/^CONFIG_LOCALVERSION="-\(.*\)\.[0-9]\+\.[0-9]\+\.[0-9]\+"/\1/p' "$file_kernelconfig" )
			if [[ "$config_localversion_name_from_config" != "$config_localversion_name" ]] ; then
				mistake "The config read from the config file ($file_kernelconfig) is $config_localversion_name_from_config and it differs from the name specified in ini file ($file_ini) that is $config_localversion_name"; 
			fi
		) || exit
done


echo ""
echo "Check on your own:"
echo "* Does all kernelconfig files contain correct version of mempo"
mywait

echo ""
echo "Check on your own:"
echo "* Does changelog have the correct entry"
mywait

echo "that is all."

