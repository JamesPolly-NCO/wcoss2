#!/bin/bash

cyc="00"
pdy="20260317"
model="rrfs"
outfile="${model}_${pdy}_dcom_files"

tmpfiles=""
while read line; do
    tmpfiles+="$line "
done < "${outfile}.${cyc}.exists"

du -sch $tmpfiles

