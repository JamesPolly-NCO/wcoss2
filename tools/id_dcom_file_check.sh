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

outfile="${model}_${pdy}_dcom_files"

tmpfiles=""
while read line; do
    tmpfiles+="$line "
done < "${outfile}.${cyc}.exists"

du -sch $tmpfiles

