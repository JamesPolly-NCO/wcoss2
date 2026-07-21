#!/bin/bash
# Identify DCOM files used in job run logs


if (($# != 3)); then
    echo "Usage: $0 model pdy cyc"
    echo "e.g. $0 rrfs 20260318 00"
    exit
fi
model=$1
pdy=$2
cyc=$3
cdate="${model}_${pdy}_${cyc}"

loglist="${cdate}_dcom_loglist"
outfile="${cdate}_dcom_files"

echo "Identifying jobs of:"
echo "$cdate"
echo "that use data from:"
echo "DCOM"

if [[ -e "$loglist" ]]; then
    echo "Found existing log list of jobs using DCOM (${loglist})."
    echo "Using existing log list...Move existing log list to generate a new one."
else
    echo "No existing log list found. Querying output logs for DCOM references."
    grep -rl '\/lfs\/h1\/ops\/prod\/dcom\/.* ' /lfs/h1/ops/para/output/${pdy}/${model}_*${cyc}.o* > $loglist
fi

if [[ ! -s "$loglist" ]]; then
    echo "no output captured, exiting"
    rm $loglist
    exit
fi

[[ -e "$outfile" ]] && rm -rf $outfile
[[ -e "$outfile.cleaned" ]] && rm -rf $outfile.cleaned
[[ -e "$outfile.exists" ]] && rm -rf $outfile.exists

#step 1: for each output log file, find the DCOM instances referenced:
while read line; do
    if [[ "$line" == *"_${cyc}.o"* ]]; then
        grep -ho -e "/lfs/h1/ops/prod/dcom/.*" $line >> $outfile
    fi
done < $loglist

# step 2:
# requires package by package modification.
# do some cleanup on what is captured by the step 1 grep.
while read line; do
    if [[ "$line" == *"' ']'"* ]]; then
        echo $line | sed "s/' ']'//g" >> $outfile.cleaned
    elif [[ "$line" == *"]"* ]]; then
        echo $line | sed "s/]//g" >> $outfile.cleaned
    else
        echo $line | sed "s/'//g" >> $outfile.cleaned
    fi
done < $outfile

# more cleanup with sort | uniq
sort $outfile.cleaned | uniq > $outfile.cleaned.uniq

# step 3: check for file existence
while read line; do
    if [[ "$line" == *" "* ]]; then
        for entry in $line; do
            [[ -d "$entry" ]] && continue
            stat $entry >/dev/null 2>&1
            [[ $? -eq -0 ]] && echo $entry >> $outfile.exists
        done
    else
        [[ -d "$line" ]] && continue
        stat $line >/dev/null 2>&1
        [[ $? -eq -0 ]] && echo $line >> $outfile.exists
    fi
done < $outfile.cleaned.uniq
