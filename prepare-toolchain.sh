#!/bin/bash

# Test do we have needed tool chain programs 

source support.sh

all_ok=1

echo "Looking for tools"

source dpkg-vercomp.sh

echo "-----------------------------"
echo "Dpkg"
#PATH="$HOME/.local/bin:$PATH"
#PATH="$HOME/.local/usr/bin:$PATH"
PATH="$HOME/.local/bin:$PATH" # dpkg
export PERL5LIB="$HOME/.local/share/perl5" # dpkg needs this
#export DH_AUTOSCRIPTDIR="$HOME/.local/usr/share/debhelper/autoscripts"
#export PERL5LIB="$HOME/.local/usr/share/perl5:$PERL5LIB"

echo " * testing with PATH=$PATH"
echo "Testing dpkg version"
tools_dpkg_which=$(which dpkg)
tools_dpkg_ver=$( $tools_dpkg_which --version | head -n 1 | sed -e 's/.*program version \([^ ]*\).*/\1/' )
tools_dpkg_vermempo=$( echo $tools_dpkg_ver | sed -e 's/.*-mempo\([0-9+a-zA-Z.]*\).*/\1/g' )
if [[ $tools_dpkg_vermempo == $tools_dpkg_ver ]] ; then tools_dpkg_vermempo="0.0.0.0.0.NONE"; echo "WARNING: no mempo version detected in dpkg, you are not using mempo version of dpkg" ; fi ;
# | head -n 1 | sed -e 's/.*program version \([^ ]*\).*/\1/' | sed -e 's/.*-mempo\([0-9.]*\).*/\1/g'

export tools_dpkg_which
export tools_dpkg_ver
export tools_dpkg_vermempo

ver_have=$tools_dpkg_vermempo ; ver_need="0.1.24.10"
vercomp $ver_have $ver_need
case $? in
  2) echo ; echo "ERROR: dpkg mempo version is bad (too old?)"
		echo "We have mempo-version=$ver_have (from dpkg ver $tools_dpkg_ver) while we need mempo-version=$ver_need" ; 
		echo "You probably did not install our special dpkg version, or you use too old version of it."
		echo "Please see information on https://wiki.debian.org/SameKernel/#dpkg how to install the required version."  
		echo "Usually it should be enough to install the speciall dpkg only locally as user (does not require root) so it should be very easy."
		ask_quit;
	;;
esac
echo " * Using $tools_dpkg_which with version $tools_dpkg_ver (mempo version $tools_dpkg_vermempo) needed=$ver_need" ; echo ;

mkdir -p "$HOME/.local/var/lib/dpkg/" # normally should be done by local instalation of dpkg; this allows to run without local dpkg (just a quick test run, which will
# NOT work correctly probably - e.g. will not be a SameKernel giving same binary build)

echo "Link dpkg status"
dpkg_status_target="$HOME/.local/var/lib/dpkg/status"
[ -e "$dpkg_status_target" ] && rm -rf "$dpkg_status_target"
if [ -e "$dpkg_status_target" ] ; then 
	echo "ERROR: failed to remove old dpkg status $dpkg_status_target"
	exit 2
fi
if ! ln -s /var/lib/dpkg/status "$dpkg_status_target"; then
	echo "ERROR: Could not link dpkg status"
	exit 2
fi

echo "Link dpkg info"
dpkg_info_target="$HOME/.local/var/lib/dpkg/info" 
[ -e "$dpkg_info_target" ] && rm -rf "$dpkg_info_target" # (is a file, but still -rf)
if [ -e "$dpkg_info_target" ] ; then
	echo "ERROR: failed to remove old dpkg info $dpkg_info_target"
	exit 2
fi
if ! ln -s /var/lib/dpkg/info "$dpkg_info_target"; then
	echo "ERROR: Could not link dpkg info"
	exit 2
fi
ls -ld "$dpkg_info_target"

echo "-----------------------------"
echo "Version of gcc and C libraries (embed in binaries - affecting build-id)"

count_lib_error_exact=0
count_lib_error_tool=0

function require_exact_ver() { # ($name,$ver_needed)
	name=$1
	ver_needed=$2
	ver_now=$( LC_ALL=C dpkg -s $name | grep 'Version' | head -n 1 | sed -e "s/^Version: \([^ ]*\)$/\1/" ) 
	msg="OK";
	if [[ "$ver_now" != "$ver_needed" ]] ; then
		count_lib_error_exact=$((count_lib_error_exact+1))
		msg=" WARNING: miss-matched version! [errors: $count_lib_error_exact]"
	fi
	echo " * $name: now $ver_now (need $ver_needed) $msg"
}

# (for p in libc6 gcc gcc-4.7 gcc-4.7-plugin-dev gcc-4.4-doc ; do dpkg -l $p ; done ; gcc --version ; gcc-4.7 --version) | egrep "gcc|libc"
# ii  libc6:amd64                      2.13-38+deb7u1                amd64        Embedded GNU C Library: Shared libraries
# ii  gcc                              4:4.7.2-1                     amd64        GNU C compiler
# ii  gcc-4.7                          4.7.2-5                       amd64        GNU C compiler
# ii  gcc-4.7-plugin-dev               4.7.2-5                       amd64        Files for GNU GCC plugin development.
# (no gcc-4.4-doc)
# gcc (Debian 4.7.2-5) 4.7.2
# gcc-4.7 (Debian 4.7.2-5) 4.7.2

require_exact_ver "libc6" "2.13-38+deb7u6"
require_exact_ver "gcc" "4:4.7.2-1"
require_exact_ver "gcc-4.7" "4.7.2-5"
require_exact_ver "gcc-4.7-plugin-dev" "4.7.2-5"

if [[ "$count_lib_error_exact" -gt 0 ]] ; then
	echo ; echo "ERROR: you seem to have wrong version of some library as listed above."
	echo "If you have older version then needed, then simply updating the system should help"
	echo "If you have newer version - then you are probably checking some older version of our kernel,"
	echo "then try to get new our newest kernel, kernel script."
	echo "If you really want to verify old kernel then you need to obtain the older version to get identical deb files"
	echo "(or continue, and verify the .deb by hand by unpacking and comparing files)"
	echo ""
 	echo "In theory you could also write script to override the name/version that is embed in generated elf files"
	echo "during the build. See also this: https://wiki.debian.org/SameKernel/#bug2 or ask us at #mempo"
	ask_quit;
fi


# deprecated tests - to remove later?
if false ; then

touch testfile.txt
tar --mtime "2013-12-24 23:59:01" --sort-input  -c -f testfile.tar testfile.txt
exitcode=$?
rm -f testfile.txt ; rm -f testfile.tar

if [[ 0 == "$exitcode" ]]  ; then
	echo "Ok, the global tar supports extended options"
fi

if [[ 0 != "$exitcode" ]]  ; then
  PATH="$HOME/.local/usr/bin/:$PATH"
	echo "Trying with other PATH=$PATH"

	touch testfile.txt
	tar --mtime "2013-12-24 23:59:01" --sort-input  -c -f testfile.tar testfile.txt
	exitcode=$?
	rm -f testfile.txt ; rm -f testfile.tar

	if [[ 0 == "$exitcode" ]]  ; then
		echo "Ok, the tar supports extended options"
	else
		echo "" ; echo "ERROR:"
		echo "Can not find extended tar with support for --sort-input"
		echo "Please install it from: "
		echo "  https://github.com/mempo/mempo-deb/ once this is ready, or while not available use:"
		echo "  https://github.com/mempo/various/tree/master/tar once this is ready, or while not available use:"
		exit_error # error
	fi
fi

# TODO test also /opt/ and /usr/local/ ?

echo "Final PATH=$PATH"

# export FAKETIME_TIME="$TIMESTAMP_RFC3339" ; # '1970-12-30 18:00:01'

fi


