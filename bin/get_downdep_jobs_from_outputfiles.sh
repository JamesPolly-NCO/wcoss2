#!/bin/bash

outfile=downstream_jobs_using_rtofs_data
rm -f $outfile

pkglist=($(grep 'rtofs_ver' /lfs/h1/ops/prod/packages/*/versions/run.ver | sed 's/\/versions\/run\.ver..*//'))
#echo ${pkglist[@]}
for element in "${!pkglist[@]}"; do
	echo "${pkglist[$element]}"
	pkgname=$(echo "${pkglist[$element]}" | sed 's/\/lfs\/h1\/ops\/prod\/packages\///' | sed 's/\.v..*//')
	#echo "grep -l '\/lfs\/h1\/ops\/prod\/com\/rtofs\/v2\.4\/' /lfs/h1/ops/prod/output/20250723/*"$pkgname"*"
	grep -l '\/lfs\/h1\/ops\/prod\/com\/rtofs\/v2\.4\/' /lfs/h1/ops/prod/output/20250723/*"$pkgname"* >> "$outfile".tmp
done

sort "$outfile".tmp | uniq > $outfile
rm -f "$outfile".tmp

