#!/bin/bash

cyc="00"
pdy="20260317"
model="rrfs"
outfile="${model}_${pdy}_dcom_files"

sed 's|/lfs/h1/ops/prod/dcom/||' $outfile.${cyc}.exists > include_list

echo "rsync -avhn --files-from=include_list /lfs/h1/ops/prod/dcom /lfs/h1/ops/test/dcom"

