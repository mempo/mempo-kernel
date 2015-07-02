
cp config.example  config

bash kconfig-cli-set.sh config  OPT_S=new OPT_Y1=y OPT_Y2=y OPT_M=m OPT_N=- 'OPT_L="new long string"' OPT_V1024=1024 NEW_NO=- NEW_YES=y NEW_M=m

# echo "Results:"
# diff .config.example  .config

echo 
echo 
echo "Is the file as expected after edit:"
set -x
diff config config.example.out
set +x
echo 

