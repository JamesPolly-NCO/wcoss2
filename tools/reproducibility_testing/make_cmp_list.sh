#!/bin/bash
# make a list of cmp commands to execute

if (($# != 2)); then
    echo "Usage: $0 dir1 dir2"
    echo "e.g. $0 /lfs/h1/ops/test/com/rrfs/v1.0/rrfs.20260330.hold /lfs/h1/ops/test/com/rrfs/v1.0/rrfs.20260330"
    exit
fi

dir1=$1
dir2=$2
outfile=cmp_list

[[ -e $outfile ]] && rm -rf $outfile

find $dir1 -type f > first_run
find $dir2 -type f > second_run

nfirst=$(wc -l < first_run)
nsecond=$(wc -l < second_run)

echo $nfirst
echo $nsecond

[[ "$nfirst" -ne "$nsecond" ]] && echo "Warning, different number of files"

if (( nfirst >= nsecond )); then
    shortlist=second_run
    echo "using $dir2 contents for comparision"
else
    shortlist=first_run
    echo "using $dir1 contents for comparision"
fi

while read line; do
    if [[ "$shortlist" == "first_run" ]]; then
       tmpf=$(echo $line | sed "s|$dir1|$dir2|")
    elif [[ "$shortlist" == "second_run" ]]; then
       tmpf=$(echo $line | sed "s|$dir2|$dir1|")
    fi
    echo "cmp ${line} ${tmpf}" >> $outfile
done < $shortlist

chmod +x $outfile
