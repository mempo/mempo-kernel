
echo "This script will built the packages, twice, in your HOME folder"
echo "It will without question REMOVE old data folder"
echo "This is intended for our alpha-testers and developers mainly"
echo "Are you sure? type letter y, in upper case. type n to cancel"

echo ""
echo " *** THIS SCRIPT IS NOT TESTED YET ***"
echo ""

read y

if [[ $y != "Y" ]] ; then
	echo "ok - cancel"
	exit 1
fi

echo "starting"
echo "starting..."
sleep 2

for nr in 1 2
do
	echo "====== BUILD nr=$nr ======"

	cd ~
	rm -rf deterministic-kernel/
	git clone https://github.com/mempo/deterministic-kernel.git
	cd deterministic-kernel/

	now=$(date) ; echo "RUN build nr=$nr at $now" >> ~/buildlog.txt

	bash run.sh 2>&1 | tee -a ~/builddbg.txt

	now=$(date) ; echo "DONE build nr=$nr at $now" >> ~/buildlog.txt

	cd ~
	mv deterministic-kernel deterministic-kernel-now$nr

done

