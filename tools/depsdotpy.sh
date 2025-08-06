#!/bin/bash
# depsdotpy.sh: wrapper script (and documentation) for deps.py. Performs only queries.
# James Polly 20250806
#
# usage:
#     depsdotpy.sh model ver
#     e.g.
#     depsdotpy.sh rtofs v2.5
#
# See following links for deps.py usage and syntax:
# https://www2.pmb.ncep.noaa.gov/wiki/index.php/WCOSS2_DCOM
# https://docs.google.com/spreadsheets/d/1y-i4WtctIymMIlJR6kOSiXsd3aA1qAUTfzaItEg-KIM/edit?gid=0#gid=0
#
# module use /apps/ops/para/nco/modulefiles/core
# module load prod_util intel python/3.8.6 deps
#
# Use output of query to form commands for other tasks (add, remove, etc.).
#
# Implement "write" and other non-read actions as ops.para

if (($# != 2 )); then
	echo "Error: accepts two arguments: model and ver"
	echo "usage: $0 model_name ver_num"
	echo "e.g.: $0 rtofs v2.5"
	exit
fi

model=$1
ver=$2
outfile="$model"_"$ver"_depsdotpy_query.list

#direct output of query to a file:
deps.py -m $model $ver > $outfile

