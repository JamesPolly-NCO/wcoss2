#!/bin/bash
# Use output of id_upstream_data.sh to list job names, collapsing 
# similar jobs (e.g. ensemble members {00..05}) to be represented by a single name.
#
# Provide model, pdy, and cyc.

if (($# != 3)); then
    echo "Usage: $0 model pdy cyc"
    echo "e.g. $0 rrfs 20260318 00"
    exit
fi
model=$1
pdy=$2
cyc=$3
cdate="${model}_${pdy}_${cyc}"
jobname=$4

datafile="${cdate}_jobs_files.uniq"

if [[ ! -s "$datafile" ]]; then
    echo "datafile ${datafile} not found; exiting"
    exit
fi

grep "^j${model}" $datafile \
| sed 's/_\([0-9][0-9]\)/_XX/' \
| sed 's/mem\([0-9][0-9][0-9]\)/memYYY/' \
| sort \
| uniq
