#!/bin/bash
# deps_from_outputfiles.sh: Use job output files to return lists of jobs and data used by downstream models.
# James Polly 20250731
#
# usage:
# ./deps_from_outputfiles.sh model_name
#
# e.g.:
# ./deps_from_outputfiles.sh rtofs

source funcs.sh

model=$1
jobsfile=downstream_"$model"_jobs.txt
rm -f $jobsfile

PDY=${2-$(date "+%Y%m%d")}

pkglist=($(grep ""$model"_ver" /lfs/h1/ops/prod/packages/*/versions/run.ver \
	| sed 's/\/versions\/run\.ver..*//' \
	| sed 's/\/lfs\/h1\/ops\/prod\/packages\///' | cut -d'.' -f1 | sort | uniq))
#echo ${pkglist[@]}
for element in "${!pkglist[@]}"; do
	pkgname="${pkglist[$element]}"
	ver_latest=$(get_latest_pkg_ver $pkgname)
	echo "$pkgname"."$ver_latest"
	#echo "grep -l '\/lfs\/h1\/ops\/prod\/com\/$model\/' /lfs/h1/ops/prod/output/"$PDY"/*"$pkgname"*"
	grep -l "\/lfs\/h1\/ops\/prod\/com\/$model\/" /lfs/h1/ops/prod/output/"$PDY"/*"$pkgname"* >> "$jobsfile".tmp
done

sort "$jobsfile".tmp | uniq > $jobsfile
rm -f "$jobsfile".tmp

