# place for STATIC settings that could change between releases
export kernel_general_version="3.2.58" # base version (should match the one is sources.list)
export KERNEL_DATE='2014-04-30 00:10:00' # UTC time of mempo version. This is > then max(kernel,grsec,patches) times
export CURRENT_SEED='' # nothing up my sleeve number (*)
export DEBIAN_REVISION="00" # see README.md how to update it on git tag, on rc and final releases

# (*) from newest (at release, -6 blocks) http://blockchain.info/block-index/ or http://blockexplorer.com/
# Nothing up my sleeve number, unknown in advance even to me in a provable way - e.g. bitcoin markel root of recent block. 
