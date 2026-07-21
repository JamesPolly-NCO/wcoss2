#!/bin/bash
# Execute after running id_dcom_data.sh

if (($# != 3)); then
    echo "Usage: $0 model pdy cyc"
    echo "e.g. $0 rrfs 20260318 00"
    exit
fi
model=$1
pdy=$2
cyc=$3

cdate="${model}_${pdy}_${cyc}"
outfile="${cdate}_dcom_files"

tmpfiles=""
while read line; do
    tmpfiles+="$line "
done < "${outfile}.exists"

du -sch $tmpfiles

