
echo "This script will build the packages, twice, in your HOME folder"
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
sleep 1
echo "starting..."
sleep 2

log1="$HOME/buildlog.log"
log2="$HOME/builddbg.log"

for nr in 1 2
do
	echo "============================================" | tee -a "$log1" "$log2" 
	echo "=============== BUILD nr=$nr ===============" | tee -a "$log1" "$log2" 
	echo "============================================" | tee -a "$log1" "$log2" 

	now=$(date) ; echo "TOP LEVEL RUN build nr=$nr at $now" >> "$log1"

	cd ~
	rm -rf ~/deterministic-kernel/
	git clone https://github.com/mempo/deterministic-kernel.git
	cd ~/deterministic-kernel/

	now=$(date) ; echo "Will executed run.sh at $now" >> "$log1"

	bash run.sh 2>&1 | tee -a "$log2"

	now=$(date) ; echo "TOP LEVEL DONE build nr=$nr at $now" >> "$log1"

	cd ~
	rm -rf ~/deterministic-kernel-now$nr
	mv ~/deterministic-kernel ~/deterministic-kernel-now$nr

done

