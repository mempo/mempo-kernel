#!/bin/bash -e
# Do NOT call this directly, see readme. See and update build-system.txt
# Main file that starts the build when all the sources are unpacked

echo "Rebuilding everything"

bash get-sources.sh "$@" || exit 

if [[ "$*" == *edit_config* ]] # http://superuser.com/questions/186272/check-if-any-of-the-parameters-to-a-bash-script-match-a-string / http://superuser.com/a/186304
then
	make menuconfig
	echo "Ok all done. Remember to copy the new .config from here to up to proper template"
	echo "Starting a bash for that. When you are done then do exit"
	bash
	echo "Ok, back to building then."
fi

bash build-run.sh "$@" || exit

