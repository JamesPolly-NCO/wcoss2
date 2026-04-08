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

nfirst=$(wc -l first_run)
nsecond=$(wc -l second_run)

[[ "$nfirst" != "$nsecond" ]] && echo "Warning, different number of files"

if (( nfirst >= nsecond )); then
    shortdir=$dir2
else
    shortdir=$dir1
endif

while read line; do
    if [[ "$shortdir" == "$dir1" ]]; then
       tmpf=$(echo $line | sed "s|$dir1|$dir2|")
    elif [[ "$shortdir" == "$dir2" ]]; then
       tmpf=$(echo $line | sed "s|$dir2|$dir1|")
    fi
    echo "cmp ${line} ${tmpf}" >> $outfile
done < $shortdir

chmod +x $outfile
