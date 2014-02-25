deterministic-kernel
====================

Deterministic kernel build scripts, for Linux, mainly for Debian for now.

This scripts will build kernel in deterministic way, and also apply our default 
settings and patches.

https://wiki.debian.org/SameKernel
https://wiki.debian.org/Mempo


Security
====================

You should verify data with both github.com by https/SSL or SSH downloads
and you should check git tag -v _tagname_ e.g.:   git tag -v v0.1.26-rc3
to see if tag is signed by: pgp key 45953F23 rfree-mempo, pubkey here in doc/
full id: 21A5 9D31 7421 F02E C3C3  81F3 4623 E8F7 4595 3F23

Donations address for some people that will help this project (and entire Mempo
project) is here in doc/donations.txt, make sure you obtained this information
from trusted source! It should be also PGP signed.

TRUST CHAIN currently:
 * in future we will release very-high trusted master pgp key to sign everything else, once secure
 enough computer is ready to use.
 * github.com/mempo/ is medium-high security (used by SSH from quite secured computer)
 * pgp key 45953F23 is medium-high security (will be replaced leter)
 * mempo.org website currently is low-medium security (just a rented server)!
 * wiki.debian.org/ is nice but very-low, ANYONE can edit it!

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
* changelog
* reset _RR_=0 as written above
* linux-mempo/configs/(every).config - write the proper version in `CONFIG_LOCALVERSION`
* change CURRENT_SEED in env.sh

When upstream grsecurity/patches change, then update:
* changelog
* sources.list - the checksum and file name of patch
* linux-mempo/env.sh - `KERNEL_DATE`
* increase _M.M.M_ as written above

When new upstream vanilla kernel (_V.V.V_)
* changelog
* sources.list - the checksum and file name of kernel
* linux-mempo/env.sh - `kernel_general_version` and `KERNEL_DATE`
* increase _M.M.M_

