#!/bin/bash

# deterministic build:
export TIMESTAMP_RFC3339='2013-08-05 21:51:00-00:00'
export KCONFIG_NOTIMESTAMP=1
export KBUILD_BUILD_TIMESTAMP=`date -u -d "${TIMESTAMP_RFC3339}"`
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=host
export ROOT_DEV=FLOPPY

# debian make-kpkg related:
export DEBIAN_REVISION="01"

