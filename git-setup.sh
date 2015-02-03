
function addobject {
	git remote add "$1" "$2" # new one
	git remote set-url "$1" "$2" # in case it existed but with other URL, here we change it
}

addobject mempomisc git@github.com:mempomisc/mempo-kernel.git
addobject rfree git@github.com:rfree/mempo-kernel.git
addobject 0x20c24 git@github.com:0x20c24/deterministic-kernel.git

git fetch --all

