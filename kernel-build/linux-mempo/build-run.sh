#!/bin/bash -e
# run get-sources.sh before this.
# Do NOT run this file, use all.sh

# linuxdir = linux-3.2.48   used to create linux-3.2.48.tar file name,
# dir names etc.


. env.sh
echo "kernel_general_name=$kernel_general_version" # from env.sh
export linuxdir="linux-$kernel_general_version" # e.g.: linux-3.2.53
echo "Working on linux sources in linuxdir=$linuxdir"

match='^[-a-zA-Z0-9]+[-.a-zA-Z0-9]*$'; dir="$linuxdir" ; [[ "$dir" =~ $match ]] || { echo "ERROR invalid directory name ($dir)"; exit 1 ; }
rm -rf $dir

out="mempo-report-$kernel_general_name-5.txt"

echo ""
echo "=== PATCH ======================================"
bash patch.sh "$linuxdir" || { echo "ERROR: in the patch.sh step" ; exit 1 ; }

echo ""
echo "=== BUILD ======================================"
bash build.sh "$linuxdir" || { echo "ERROR: in the build.sh step" ; exit 1 ; }

echo ""
echo "=== READY ======================================"
echo "Mempo kernel (debian+grsecurity+patches) - build report (5 - output)" > $out

echo "Builded from sources_id:" >> $out
cat sources_id.txt >> $out

echo "" >> $out
echo "Builded from system_id:" >> $out
cat system_id.txt >> $out
echo "With system files:" >> $out
sha1sum /etc/kernel-img.conf  /etc/kernel-pkg.conf >> $out

rm sources_id.txt
rm system_id.txt

echo "" >> $out
echo "Builded with compiler: " >> $out
gcc -v &>> $out

echo "" >> $out
echo 'Following files where created:' >> $out
sha1sum *.deb "${linuxdir}/.config" >> $out
echo "" >> $out
sha256sum *.deb "${linuxdir}/.config" >> $out

echo "ALL DONE"
echo
