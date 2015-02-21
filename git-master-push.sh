#!/bin/bash -e

git fetch --all --tags 
echo "pause... enter to continue" ; read _

git merge --ff-only mempo/master 
git merge --ff-only rfree/master 
git merge --ff-only mempomisc/master 
git merge --ff-only 0x20c24/master

echo "--- log (files) ---"

git log --show-signature  --name-only HEAD^^^..HEAD

echo "--- log (info) ---"
git log --show-signature  HEAD^^..HEAD | head -n 50

echo "pause... enter to continue: CHCK IF LOG IS OK (is that latest commit?)" ; read _

echo "Choose tag"
git tag

echo "What tag should we sign with?"
read tag

echo "---------------------------------------------------------------"
git log --show-signature  HEAD^^..HEAD | head -n 50
echo "---------------------------------------------------------------"
head -n 10 changelog
echo "---------------------------------------------------------------"
cat cannary.txt
echo "" ; echo "^--- copy paste the above (and press ENTER)" ; read _

git tag -s $tag

git tag

echo "pause... enter to continue" ; read _

git push --tags
git push --all

echo "done"


