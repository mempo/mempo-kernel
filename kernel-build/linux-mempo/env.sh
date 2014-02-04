#!/bin/bash
# place for extra settings that could change between releases, and with updates of code and versions

# general:
export kernel_general_version="3.2.54" # script uses this setting

# deterministic build:
export KERNEL_DATE='2014-01-28 23:50:00' # (included +5h timezone)

# debian make-kpkg related:
export DEBIAN_REVISION="04" # see README.md how to update it on git tag, on rc and final releases

# conversions etc (do not change this)
export TIMESTAMP_RFC3339=$KERNEL_DATE

