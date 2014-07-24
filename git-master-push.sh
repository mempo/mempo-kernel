#!/bin/bash -e

git fetch --all --tags 
echo "pause... enter to continue" ; read _

git merge --ff-only rfree/master 
echo "--- log ---"
git log | head
echo "pause... enter to continue: CHCK IF LOG IS OK (is that latest commit?)" ; read _

git tag

echo "What tag should we sign with?"
read tag

git tag -s $tag 
git tag

echo "pause... enter to continue" ; read _

git push --tags
git push --all

echo "done"


