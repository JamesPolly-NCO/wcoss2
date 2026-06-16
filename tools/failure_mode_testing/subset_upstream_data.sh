#!/bin/bash
# Use output of id_upstream_data.sh to subset that output by job name.
#
# Provide model, pdy, cyc, and jobname.
# Output the files identified by id_upstream_data.sh for that jobname.
#
# Second of two scripts to be used in sequence for failure mode testing:
# 1. id_upstream_data.sh
# 2. subset_upstream_data.sh

if (($# != 4)); then
    echo "Usage: $0 model pdy cyc jobname"
    echo "e.g. $0 rrfs 20260318 00 jrrfs_det_analysis_gsi"
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

sed -n "/$jobname/,/^jrrfs/{/^jrrfs/!p}" $datafile
