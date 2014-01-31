#!/bin/bash
# place for extra settings that could change between releases, and with updates of code and versions

# general:
export kernel_general_version="3.2.54" # script uses this setting

# deterministic build:
export TIMESTAMP_RFC3339='2014-01-09 23:40:00' # grsecurity-3.0-3.2.54-201401091839.patch 01/09/14 18:40  +5 h timezone

# debian make-kpkg related:
export DEBIAN_REVISION="11" # see README.md how to update it on git tag, on rc and final releases

