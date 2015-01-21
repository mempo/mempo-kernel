deterministic-kernel
====================

Deterministic kernel build scripts, for Linux, mainly for Debian for now.

This scripts will build kernel in deterministic way, and also apply our default 
settings and patches. 

It will also use Grsecurity patch to create secure hardened grsecurity/pax kernel (optional).

How to build
====================
See doc/build.txt

How to use
====================
As end user who just wishes to run a Grsecurity kernel on Debian,
see http://deb.mempo.org (check the GPG key as given below).

Security
====================

_READ FILE security.txt here for list of known existing and past problems._

You should verify data with both github.com by https/SSL or SSH downloads
and you should check git tag -v _tagname_ e.g.:   git tag -v v0.1.26-rc3
to see if tag is signed by: pgp key 45953F23 rfree-mempo, pubkey here in doc/

*Do read* the doc/pgp.txt.sig file that is signed version of doc/pgp.txt;
Public key files are in doc/ too.

updating this project
====================

First of, read the details in doc/build.txt and rest of doc/ folder!

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
* sourcecode.list - the checksum and file name of patch
* linux-mempo/env.sh - `KERNEL_DATE`
* increase _M.M.M_ as written above

When new upstream vanilla kernel (_V.V.V_)
* changelog
* sourcecode.list - the checksum and file name of kernel
* linux-mempo/env.sh - `kernel_general_version` and `KERNEL_DATE`
* increase _M.M.M_

