#!/bin/bash

normal_exit=n
function my_die() {
	echo "ERROR occured: $*"
	normal_exit='y'
	exit 1
}

argument_input="$1"
shift
if ! [[ -r "$argument_input" ]] ; then my_die "Can not read input file ($argument_input)" ; fi

tempdir=''

function cleanup() {
	fname="$tempdir"
	if [[ $normal_exit != 'y' ]] ; then echo "Deleting ($fname)" ; fi
}
trap cleanup EXIT


tempdir=$(mktemp -d)
if [[ ! -d "$tempdir" ]] ; then my_die "Temp dir failed ($tempdir)" ; fi
chmod 700 "$tempdir" || my_die "Rights on temp dir failed ($tempdir)"


function change_one_setting() {
	N="$1" # name like CONFIG_EDAC_DEBUG 
	V="$2" # value like 'y' ; sed -e "s/# $N is not set/$N=$V/"
	if ! [[ $N =~ [A-Z][A-Z0-1]* ]] ; then
			my_die "Bad name of option ($N)"
	fi
	
	if [[ -z "$V" ]] ; then echo "Warning: empty value used for option ($N)" ; fi
	if [[ "$V" == 'n' ]] ; then echo "Warning: value 'n' is used, if you want to configure option to No then set it to value '-' (minus sign). In option ($N)" ; fi
	if [[ "$V" == 'N' ]] ; then echo "Warning: value 'N' is used, if you want to configure option to No then set it to value '-' (minus sign). In option ($N)" ; fi

	if [[ $V =~ .*\".* ]] ; then my_die "Do NOT use quotation markers in the value (sorry we do not support multi-word edits now yet, but it's easy to hack in just use function change_one_setting" ; fi

	if [[ $V =~ .*\'.*\'* ]] ; then my_die "Do NOT use quotation markers in the value (sorry we do not support multi-word edits now yet, but it's easy to hack in just use function change_one_setting" ; fi
	# this above regexp is just: .*\'.* meaning .*'.* so any string that contains single-quote (') character, the additional string '* at end is just to fix some source code editors that get confused here (e.g. vim in debian 7)
	
	if [[ $V == '-' ]] ;
	then
		sed -e "s/^# $N is not set\$/# $N is not set/" < "$argument_input" > "$tempdir/new1"
		sed -e "s/^$N=.*\$/# $N is not set/" < "$tempdir/new1" > "$tempdir/new2"
	else
		sed -e "s/^# $N is not set\$/$N=$V/" < "$argument_input" > "$tempdir/new1"
		sed -e "s/^$N=.*\$/$N=$V/" < "$tempdir/new1" > "$tempdir/new2"
	fi

	# diff "$argument_input" "$tempdir/new2"
	cp "$tempdir/new2" "$argument_input"
}

# change_one_setting 'CONFIG_EDAC_DEBUG' 'n'
# change_one_setting 'CONFIG_EDAC_DEBUG' ''
# change_one_setting 'FOO' 'y'
# change_one_setting 'FOO200' 'y'
# change_one_setting '' 'y'
# change_one_setting 'FOO' "aa'bb"

cp "$argument_input" "$tempdir/start"

for pair in $*
do
	# echo "REPLACE: ${pair}"
  # split line at "=" sign
	IFS_OLD="$IFS"
	IFS="="
	read -r VAR VAL <<< "${pair}"
	IFS="${IFS_OLD}"
	change_one_setting "$VAR" "$VAL"
done

diff "$tempdir/start" "$argument_input"

normal_exit='y'

