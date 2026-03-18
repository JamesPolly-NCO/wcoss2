#!/bin/bash

if (($# != 3)); then
    echo "Usage: $0 model pdy cyc"
    echo "e.g. $0 rrfs 20260318 00"
    exit
fi
model=$1
pdy=$2
cyc=$3

outfile="${model}_${pdy}_dcom_files"

sed 's|/lfs/h1/ops/prod/dcom/||' $outfile.${cyc}.exists > include_list

echo "rsync -avhn --files-from=include_list /lfs/h1/ops/prod/dcom /lfs/h1/ops/test/dcom"

