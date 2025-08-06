#!/bin/bash
# find_outfile_from_task.sh: searches for job output files based on ecflow task paths
# James Polly 20250731
#
# usage:
# ./find_outfile_from_task.sh /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep decflow01 31415
#
# or to find an older output file provide YYYYYMMDD as arg:
# ./find_outfile_from_task.sh /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep decflow01 31415 20250728
#
# test cases:
# /prod/primary/12/hmon/v3.2/hmon2/jhmon_relocate
# /prod/primary/12/stofs/v2.1/3d_atl/jstofs_3d_atl_prep
# /para/primary/06/gfs/v16.3/gfs/wave/prep/jgfs_wave_prep
# /prod/primary/18/obsproc/v1.2/nam/18z/tm00/dump/jobsproc_nam_dump_alert

if (($# != 3 )); then
	echo "Error: accepts three arguments: path host port"
	echo "usage:"
	echo "     find_outfile_from_task.sh /path/to/node decflow0? 31415"
	exit
fi

module load ecflow
source $HOME/tools/funcs.sh

ecf_path=$1
ecf_host=$2
ecf_port=$3

model=$(echo $ecf_path | cut -d'/' -f5)
echo "Looking for package: "$model""
ecf_cyc=$(echo $ecf_path | cut -d'/' -f4)
echo "Looking for cycle: "$ecf_cyc""
echo "Looking for ecFlow task: "$ecf_path""

PDY=${4-$(date "+%Y%m%d")}

ver_latest=$(get_latest_pkg_ver $model)

pkgdir=/lfs/h1/ops/prod/packages/"$model"."$ver_latest"
echo "Found latest version: "$ver_latest""
echo "Location: "$pkgdir""
echo ""

ecf_file_name=$(ecflow_client --host=$ecf_host --port=$ecf_port --query=variable $1:ECF_SCRIPT | rev | cut -d'/' -f1 | rev)
ecf_file_path=$(find "$pkgdir"/ecf -name "$ecf_file_name")
pbs_pattern=$(grep -hi 'PBS .*-N .*' $ecf_file_path | cut -d' ' -f3 | sed "s/%[a-zA-Z][a-zA-Z]*%/*/g" | sed "s/_/*/g")

echo "searching for: $pbs_pattern"
echo 'ls -l /lfs/h1/ops/prod/output/$PDY/$pbs_pattern.o*'
[ $(ls /lfs/h1/ops/prod/output/$PDY/$pbs_pattern.o* 2>/dev/null | wc -w) = 0 ] \
	&& echo "...no output files found" && exit
echo "..."
ls -l /lfs/h1/ops/prod/output/$PDY/$pbs_pattern.o*
