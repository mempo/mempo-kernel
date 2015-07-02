
cd ~/kernel/kernel-build/linux-mempo/linux-3.2.69

for i in ~/kernel/kernel-build/linux-mempo/configs-kernel/*desk* ~/kernel/kernel-build/linux-mempo/configs-kernel/*serv*
do 
	cp "$i" .config ; make oldconfig && cp .config "$i" ; 
done


