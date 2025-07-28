#!/bin/bash
if (($# != 1)); then
        echo "usage: $0 pkg_name"
	echo "e.g.: $0 rtofs"
        exit
fi

outfile="downstream_jobs"
rm $outfile

modelname=$1
echo "grep '"$1"_ver' /lfs/h1/ops/prod/packages/*/versions/run.ver | sed 's/\/versions\/run\.ver..*//'"

echo "Writing to $(realpath $outfile)"

pkglist=($(grep "$1"_ver /lfs/h1/ops/prod/packages/*/versions/run.ver | sed 's/\/versions\/run\.ver..*//'))
echo ${pkglist[@]}
for tmppkg in "${!pkglist[@]}"; do
	echo "Package: ${pkglist[$tmppkg]}" >> $outfile
	jjoblist=($(grep -lr 'rtofs_ver' ${pkglist[$tmppkg]}/jobs/*))
	#grep -lr 'rtofs_ver' ${pkglist[$tmppkg]}/jobs/*
	echo "J-jobs:" >> $outfile
	for tmpjob in "${!jjoblist[@]}"; do
		echo "${jjoblist[$tmpjob]}" >> $outfile
		echo "ecFlow Jobs:" >> $outfile
		grep -ilr $(basename ${jjoblist[$tmpjob]}) ${pkglist[$tmppkg]}/ecf/* >> $outfile
	done
	echo "" >> $outfile
done

