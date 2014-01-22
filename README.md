deterministic-kernel
====================

Deterministic kernel build scripts, for Linux, mainly for Debian for now.

This scripts will build kernel in deterministic way, and also apply our default 
settings and patches.

https://wiki.debian.org/ReproducibleBuildsKernel

Currently working:
mostly same *content* when you unpack the .deb and then unpack the .gz (and skip symlinks!) 
calculated the sha sums there.

Under some conditions - try same user name/path, maybe host - see the Wiki.


see
====================

Read also instruction.txt 



updating this project
====================

Maintainers of this project should do following in reaction to new version of codes:

When releasing new tag -rcX
* write to changelog
* write DEBIAN REVISION="X" to env.sh (was "0X" like "09" at some point)

When doing an increase version of this script, then update:
* linux-3.2.53-mempo-X.Y.Z-shell/ - rename this directory to proper version
* linux-3.2.53-mempo-X.Y.Z-shell/configs/XYZ.config - write the proper version in CONFIG LOCALVERSION
* changelog
* write DEBIAN REVISION="X" to env.sh for finall tag. Maybe 50 = final?

Also when upstream vanilla kernel changes (version from kernel.org), then update:
* increase version
* sources.list - the checksum and file name of kernel
* linux-3.2.53-mempo-0.1.20-shell/env.sh - this date of sources
* run.sh - the kernel file variable - the file name

When upstream grsecurity/patches change, then update:
* increase version
* sources.list - the checksum and file name of patch
* linux-3.2.53-mempo-0.1.20-shell/env.sh - the date of sources

