#!/bin/bash

cp /home/kernelbuild.pub/*.sig sig/

( cd /home/kernelbuild.pub/ ; sha256sum *deb | sort -k 2 ) > SHA256.SUMS.txt
( cd /home/kernelbuild.pub/ ; sha512sum *deb | sort -k 2 ) > SHA512.SUMS.txt
( cd /home/kernelbuild.pub/ ; whirlpooldeep *deb | sort -k 2 ) > WHIRLPOOL.SUMS.txt

