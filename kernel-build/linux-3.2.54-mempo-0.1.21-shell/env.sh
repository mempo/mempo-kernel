#!/bin/bash

# deterministic build:
export TIMESTAMP_RFC3339='2014-01-05 21:50:00' # grsecurity-3.0-3.2.53-20131226 20 18.patch +5 h timezone
export KCONFIG_NOTIMESTAMP=1
export KBUILD_BUILD_TIMESTAMP=`date -u -d "${TIMESTAMP_RFC3339}"`
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=host
export ROOT_DEV=FLOPPY

# debian make-kpkg related:
export DEBIAN_REVISION="01"

