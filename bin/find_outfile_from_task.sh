#!/bin/bash
# find_outfile_from_task.sh: searches for job output files based on ecflow task paths
# James Polly 20250731
#
# usage:
# ./find_outfile_from_task.sh /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep
#
# or to find an older output file provide YYYYYMMDD as arg:
# ./find_outfile_from_task.sh /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep 20250728
#
# test cases:
# /prod/primary/12/hmon/v3.2/hmon2/jhmon_relocate
# /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep

source funcs.sh

ecf_path=$1
model=$(echo $ecf_path | cut -d'/' -f5)
echo "Looking for package: "$model""
ecf_cyc=$(echo $ecf_path | cut -d'/' -f4)
echo "Looking for cycle: "$ecf_cyc""
echo "Looking for ecFlow task: "$ecf_path""

PDY=${2-$(date "+%Y%m%d")}

ver_latest=$(get_latest_pkg_ver $model)

pkgdir=/lfs/h1/ops/prod/packages/"$model"."$ver_latest"
echo "Found latest version: "$ver_latest""
echo "Location: "$pkgdir""
echo ""

jecf_task_name=$(echo $ecf_path | rev | cut -d'/' -f1 | rev)
ecf_node_name=$(echo $jecf_task_name | cut -c2-)
ecf_node_pattern=$(echo $ecf_node_name | sed "s/_/.*/g")

echo "Matching .ecf files containing PBS directives matching: $ecf_node_pattern"
echo 'grep -i "PBS .*-N .*$ecf_node_pattern" $(find "$pkgdir"/ecf -name "*.ecf")'
echo "..."
grep -i "PBS .*-N .*$ecf_node_pattern" $(find "$pkgdir"/ecf -name "*.ecf")
echo "" && echo "Check for output files based on these PBS job names:"

#grep -h "PBS .*-N .*$ecf_node_name" $(find "$pkgdir"/ecf -name "*.ecf") | sed "s/%CYC%/$ecf_cyc/g" | cut -d' ' -f3
for tmppbsvar in $(grep -h "PBS .*-N .*$ecf_node_pattern" $(find "$pkgdir"/ecf -name "*.ecf") | cut -d' ' -f3); do
	tmppbsname=$(echo "$tmppbsvar" | sed "s/%[a-zA-Z][a-zA-Z]*%/*/g" | sed "s/_/*/g")
	echo "searching for: $tmppbsname"
	echo 'ls -l /lfs/h1/ops/prod/output/$PDY/$tmppbsname.o*'
	[ $(ls /lfs/h1/ops/prod/output/$PDY/$tmppbsname.o* 2>/dev/null | wc -w) = 0 ] \
		&& echo "...no output files found" && echo "" && continue
	echo "..."
	ls -l /lfs/h1/ops/prod/output/$PDY/$tmppbsname.o*
	echo ""
done
