#!/bin/bash
# Run list of cmp commands and provide output

infile=cmp_list

[[ ! -e "$infile" ]] && echo "$infile not found, exiting." && exit 0

./${infile} > ${infile}.out 2>&1
