#!/bin/bash -e

# THE MAIN FILE :-)
# run me.

echo "Rebuilding everything"

bash get-sources.sh || exit 
bash build-run.sh || exit

