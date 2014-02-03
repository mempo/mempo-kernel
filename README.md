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

```
    linux-image-3.2.54-grsec-mempo.good.0.1.21_01_amd64.deb
		            VVVVVV             LLLL MMMMMM RR AAAAA

V.V.V - vanilla kernel
M.M.M - version of Mempo, increased with grsecurity updates; usullay with other config
RR    - release. for now is set to -RC (and 50 for finall)
LLLLL - level of security (will be option in future)
AAAAA - architecture (will be option in future)
```

When releasing new tag (_RR_)
* changelog
* `DEBIAN_REVISION="X"` in env.sh

When incresing Mempo (_M.M.M_)
* reset _RR_=0
* linux-mempo/configs/(every).config - write the proper version in `CONFIG_LOCALVERSION`

When upstream grsecurity/patches change, then update:
* sources.list - the checksum and file name of patch
* increase _M.M.M_
* linux-mempo/env.sh - `KERNEL_DATE`

When new upstream vanilla kernel (_V.V.V_)
* sources.list - the checksum and file name of kernel
* linux-mempo/env.sh - `kernel_general_version` and `KERNEL_DATE`
* increase _M.M.M_
* changelog

