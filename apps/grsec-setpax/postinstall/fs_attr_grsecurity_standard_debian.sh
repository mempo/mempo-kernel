#!/bin/bash
# This sets Grsecurity Pax flags for commonly used files on Debian.
# see: https://wiki.debian.org/grsecurity
# see: http://mempo.org , wiki.debian.org/Mempo - and contact us for help in case of questions.
# (This assumes the kernel Grsecurity Pax is using file attr as flags, as e.g. in Mempo)

# You needed package: attr (for command setfattr)

# This programs do NOT have proper protection form kernel, it is disabled to let them run!
# mempo.org project will aim to remedy this one day by turning runtime-JIT to separated precompile

set -x

setfattr -n user.pax.flags -v "rm" /usr/lib/xulrunner-*/xulrunner-stub 
setfattr -n user.pax.flags -v "rm" /usr/lib/iceweasel/iceweasel # debian 7
setfattr -n user.pax.flags -v "rm" /usr/lib/icedove/icedove-bin
setfattr -n user.pax.flags -v "rm" /usr/lib/icedove/icedove
setfattr -n user.pax.flags -v "rm" /usr/lib/iceowl/iceowl-bin # debian 6

# tricky part is to run this in between upgrade of kernel for reinstalling/updating grub
setfattr -n user.pax.flags -v "m"  /usr/sbin/grub-*
setfattr -n user.pax.flags -v "m"  /usr/sbin/grub-mkdevicemap
setfattr -n user.pax.flags -v "m"  /usr/bin/grub-mount
setfattr -n user.pax.flags -v "m"  /usr/bin/grub-script-check
setfattr -n user.pax.flags -v "m"  /usr/lib/grub/i386-pc/grub-setup

setfattr -n user.pax.flags -v "m"  /usr/lib/libreoffice/program/unopkg.bin
setfattr -n user.pax.flags -v "m" /usr/lib/libreoffice/program/soffice.bin

setfattr -n user.pax.flags -v "m" /usr/lib/valgrind/memcheck-*-linux

# it could be needed to reinstall java before and after, as part of java install process runs java

setfattr -n user.pax.flags -v "m"  /usr/lib/jvm/*/jre/lib/*/*.so  /usr/lib/jvm/*/jre/bin/*  

# to gedit plugins 
setfattr -n user.pax.flags -v rm /usr/bin/gedit  


setfattr -n user.pax.flags -v rm /usr/bin/qtcreator
setfattr -n user.pax.flags -v rm /usr/lib/chromium/*


set +x

# all this problems will be resolved once we have hooks that run this script when other packages are installed
# please contact us #mempo @ irc.oftc.net and ircp2 if you can help with this                 

echo "Script done. If you need go to mempo.org or debian.org or grsecurity.net" 
