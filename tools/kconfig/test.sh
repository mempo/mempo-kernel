
cp .config.example  .config

bash kconfig-cli-set.sh .config OPT_Y=- OPT_N=y OPT_S=newname OPT_V=1024 OPT_M=y

# echo "Results:"
# diff .config.example  .config

echo 
echo 
echo "Is the file as expected after edit:"
diff .config .config.example2
echo 

