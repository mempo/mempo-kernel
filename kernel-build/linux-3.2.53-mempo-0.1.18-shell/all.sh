#!/bin/bash -e

# THE MAIN FILE :-)
# run me.

echo "Rebuilding everything"

bash get-sources.sh || exit 

if [[ "$*" == *edit_config* ]] # http://superuser.com/questions/186272/check-if-any-of-the-parameters-to-a-bash-script-match-a-string / http://superuser.com/a/186304
then
	make menuconfig
	echo "Ok all done. Remember to copy the new .config from here to up to proper template"
	echo "Starting a bash for that. When you are done then do exit"
	bash
	echo "Ok, back to building then."
fi

bash build-run.sh || exit

