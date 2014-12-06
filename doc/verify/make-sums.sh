#!/bin/bash -e

mkdir -p sig || { echo "Can not make the dir for signatures" ; exit 1; }

cp /home/kernelbuild.pub/sign/*.sig sig/ || { echo "Can not copy"; exit 1; }


( cd sig/ ; sha1sum -- *sig | sort -k 2 ) > SHA1.SUMS.txt
( cd sig/ ; sha256sum -- *sig | sort -k 2 ) > SHA256.SUMS.txt
( cd sig/ ; sha512sum -- *sig | sort -k 2 ) > SHA512.SUMS.txt
( cd sig/ ; whirlpooldeep -l -- *sig | sort -k 2 ) > WHIRLPOOL.SUMS.txt

