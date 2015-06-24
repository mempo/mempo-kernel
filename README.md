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

Path and root of trust is following:
1)
 * we own https://github.com/mempo/
 * we own mempo.org [site is still being moved to new server, sorry]
 * it is known that user <rfree> is one of main developers, available on IRC, reddit, darknets
2)
 * on this sites, and/or with rfree, you can confirm our main GPG keys:
 * 33D3 8C87 97A7 A35E D8BC  AF1F 4EBE 40EA EFF6 2C7F - key rfree, medium
 * 21A5 9D31 7421 F02E C3C3  81F3 4623 E8F7 4595 3F23 - key rfree-mempo, medium
3) 
 * this PGP keys sign git commits of the sources of this project
 * this PGP keys sign also the debian repository
4)
they also sign this file here, that says that binary repository is available:
 * on https://deb.mempo.org [site moved]
 * on Freenet page (that you can open by installing and running special open-source
 program "Freenet") on address: http://127.0.0.1:8888/USK@oRy7ltZLJM-w-kcOBdiZS1pAA8P-BxZ3BPiiqkmfk0E,6a1KFG6S-Bwp6E-MplW52iH~Y3La6GigQVQDeMjI6rg,AQACAAE/deb.mempo.org/54/
 * you can trust things on the Freenet page, because the sites are alaways fully signed
5)
 * This README.md file that you read here now, should itself also be signed (e.g. in file README.md.asc)

_READ FILE security.txt here for list of known existing and past problems._

When using git, then:

You should verify data with both github.com by https/SSL or SSH downloads
and you should check git tag -v _tagname_ e.g.:   git tag -v v0.1.26-rc3
to see if tag is signed by: pgp key 45953F23 rfree-mempo, pubkey here in doc/

= = = = = = = = = = = = = = =
List of PGP keys and their security levels:
33D3 8C87 97A7 A35E D8BC  AF1F 4EBE 40EA EFF6 2C7F - key rfree, medium
21A5 9D31 7421 F02E C3C3  81F3 4623 E8F7 4595 3F23 - key rfree-mempo, medium

key rfree is for preparing work for Mempo (and for many other FOSS projects)
key rfree-mempo is for more finall signature after some review, for Mempo

The security levels like "medium" are defined in IFCCS_00003_1::medium etc, see
<https://ifccs.org/ifccs00003_1> (or mirror on <http://mempo.org/#IFCCS_00003_1>)

You can confirm this keys with: 
  https://github.org/mempo/ (registered Nov 2013) 
  http://mempo.org , http://mempo.i2p , http://www.mempo.i2p/ 
  https://wiki.debian.org/Mempo#pgp (but more people can edit Wiki)
  IRC history, Freenet FMS chat history.
to assert that this PGP keys in fact are historically authorized as the established 
"Mempo" project and as user "rfree".
= = = = = = = = = = = = = = =

Bitcoin address is:
152fnfBqRjVMDvRa5LQ2upx9tJAeHnyqHC

Supporting us
====================

* See the Bitcoin address above, any amount counts even 1$
* Using this software
* Hanging around #mempo in IRC

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

