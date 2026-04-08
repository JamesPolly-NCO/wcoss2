#!/bin/bash
# Run list of cmp commands and provide output

infile=ncdumpdiff_list

[[ ! -e "$infile" ]] && echo "$infile not found, exiting." && exit 0

module load PrgEnv-intel
module load netcdf

./${infile} > ${infile}.out 2>&1
