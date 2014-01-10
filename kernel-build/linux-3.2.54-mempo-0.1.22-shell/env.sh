#!/bin/bash

# deterministic build:
export TIMESTAMP_RFC3339='2014-01-09 23:40:00' # grsecurity-3.0-3.2.54-201401091839.patch 01/09/14 18:40  +5 h timezone
export KCONFIG_NOTIMESTAMP=1
export KBUILD_BUILD_TIMESTAMP=`date -u -d "${TIMESTAMP_RFC3339}"`
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=host
export ROOT_DEV=FLOPPY

# debian make-kpkg related:
export DEBIAN_REVISION="01"

