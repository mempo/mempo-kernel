echo "This will apply many changes (edit this script)"
echo "or ENTER to continue"
read _

for i in ../../kernel-build/linux-mempo/configs-kernel/* ; do 
	echo $i 
	bash kconfig-cli-set.sh "$i" CONFIG_DEFAULT_MODIFY_LDT_SYSCALL=y # edit this line before use
done
