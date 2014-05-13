
echo " ### THIS SCRIPT will be deprecated soon, merged with the grsecurity updater ### " ; echo "enter to continue"
read _

function mywait() {
	echo "Press ENTER when you done the above instructions"
	read _ 
}
function mywait_e() {
	echo "Press ENTER when ready, I will open editor"
	read _ 
}


echo ""
echo ""
echo "Change date and seed (from -6 block on bitcoin)" ; mywait_e
vim kernel-build/linux-mempo/env-data.sh 

echo ""
echo ""
cat changelog  | grep -B 1 -A 4 linux-image | head -n 4
echo "Update version CONFIG_LOCALVERSION to mempo version" ; mywait_e
vim kernel-build/linux-mempo/configs/config-desk.config 

vim changelog

echo "Ok, increased mempo minor version (small change)"

