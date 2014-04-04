echo ""
echo "==============================================================="
echo "This script is for Mempo developers (or users wanting to hack on it)"
echo "this will take you step by step by process to upgrade Mempo for new grsecurity kernel patch"
echo "in few simple commands :) questions -> #mempo on irc.oftc.net or freenode or see mempo.org"
echo ""
echo "This is an UPDATE after grsecurity changed"
echo ""
echo "When ready press ENTER." ; read _

function mywait() {
	echo "Press ENTER when you done the above instructions"
	read _ 
}
function mywait_e() {
	echo "Press ENTER when ready, I will open editor"
	read _ 
}

echo "Update sources to github https://github.com/mempo/deterministic-kernel/ or vyrly or rfree (the newest one)" ; mywait 

echo "Read README and info how to update on https://github.com/mempo/deterministic-kernel/ (or local file README.md here)" 
mywait

echo "[MANUALLY] Download new grsec (to kernel-sources/grsecurity/)" ; mywait
echo "[MANUALLY] Download new grsec changelog" ; mywait # todo easy automatize

echo ""
ls -rtl "kernel-sources/grsecurity/"
echo "What is the file name of new grsec .patch? (copy/type the filename and press enter)"; echo -n "> " ; read gr_patch_file
gr_patch="kernel-sources/grsecurity/$gr_patch_file"
echo ""

echo "Add new textblock for new mempo version (increase with new grsec), you said grsec is $gr_patch_file" ; mywait_e
vim changelog

sha256sum $gr_patch || { echo "Can not checksum $gr_patch" ; exit 1; }
echo "Copy the above CHECKSUM and FILENAME to replace both in line with grsecurity in the file..."
mywait_e
vim kernel-build/linux-mempo/sources.list

echo "Now we will increase mempo version"
mywait
. devel-update-version.sh

