#!/bin/bash -e

git fetch --all --tags || {
	echo "Can not download remote changes - abortig"
	exit 1
}

#echo "pause... enter to continue" ; read _

count_err=0
for repo in mempo/master rfree/master mempomisc/master 0x20c24/master
do
	git merge --ff-only "$repo" || { count_err=$(( count_err+1 )) ; echo "Can not merge $repo" ; }
done

echo "OK done (errors=$count_err) merging remote changes"

if [ "$count_err" -gt "0" ]
then
	echo "**************************"
	echo "CAN NOT MERGE SOME CHANGES"
	echo "**************************"
	echo "Continue? (for example because you edited last commit message) y/n"
	read yn
	if [[ "$yn" != "y" ]] 
	then 
		exit 1
	fi
else
	echo "Remote changes merged without problems"
fi


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


