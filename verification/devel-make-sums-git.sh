#!/bin/bash

source ../../support.sh || { echo "Can not load support.sh lib"; exit 1; }

echo "This is for use of the Developers of this project"
echo "This script will make (and git commit) he verification of builds"
echo "e.g. checksums and such"

./make-sums.sh || exit_error "Can not make the checksums"

git add sig/* *.SUMS.txt
git commit sig/* *.SUMS.txt -m "Updated checksums"

echo "All ok"

