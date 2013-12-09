#!/bin/bash

# deterministic build:
export TIMESTAMP_RFC3339='2013-12-02 17:28:00'
export KCONFIG_NOTIMESTAMP=1
export KBUILD_BUILD_TIMESTAMP=`date -u -d "${TIMESTAMP_RFC3339}"`
export KBUILD_BUILD_USER=user
export KBUILD_BUILD_HOST=host
export ROOT_DEV=FLOPPY

# debian make-kpkg related:
export DEBIAN_REVISION="01"

