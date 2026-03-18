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

loglist="${model}_${pdy}_dcom_loglist"
outfile="${model}_${pdy}_dcom_files"

echo "Identifying used DCOM files for:"
echo "$model $pdy"

#!/bin/bash
if [[ -e "$loglist" ]]; then
    echo "Found existing log list of jobs using DCOM (${loglist})."
    echo "(Move existing log list to generate a new one...)"
    echo "Using existing log list...Move existing log list to generate a new one."
else
    echo "No existing log list found. Querying output logs for DCOM references."
    grep -rl '\/lfs\/h1\/ops\/prod\/dcom\/.* ' /lfs/h1/ops/para/output/${pdy}/${model}_* > $loglist
fi

[[ -e "$outfile" ]] && rm -rf $outfile
[[ -e "$outfile.$cyc" ]] && rm -rf $outfile.$cyc
[[ -e "$outfile.$cyc.cleaned" ]] && rm -rf $outfile.$cyc.cleaned
[[ -e "$outfile.$cyc.exists" ]] && rm -rf $outfile.$cyc.exists

while read line; do
    if [[ "$line" == *"_${cyc}.o"* ]]; then
        grep -ho -e "/lfs/h1/ops/prod/dcom/.*" $line >> $outfile.$cyc
    fi
done < $loglist

while read line; do
    if [[ "$line" == *"' ']'"* ]]; then
        echo $line | sed "s/' ']'//g" >> $outfile.$cyc.cleaned
    elif [[ "$line" == *"]"* ]]; then
        echo $line | sed "s/]//g" >> $outfile.$cyc.cleaned
    else
        echo $line | sed "s/'//g" >> $outfile.$cyc.cleaned
    fi
done < $outfile.$cyc

sort $outfile.$cyc.cleaned | uniq > $outfile.$cyc.cleaned.uniq

while read line; do
    if [[ "$line" == *" "* ]]; then
        for entry in $line; do
            [[ -d "$entry" ]] && continue
            stat $entry >/dev/null 2>&1
            [[ $? -eq -0 ]] && echo $entry >> $outfile.$cyc.exists
        done
    else
        [[ -d "$line" ]] && continue
        stat $line >/dev/null 2>&1
        [[ $? -eq -0 ]] && echo $line >> $outfile.$cyc.exists
    fi
done < $outfile.$cyc.cleaned.uniq
