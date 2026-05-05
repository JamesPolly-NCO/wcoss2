#!/bin/bash
# Reproducibility testing tool:
# make a list of files to compare matching patterns
# uses output from run_cmp_list.sh

if (($# < 2)); then
    echo "Specify two directories and an optional pattern to match."
    echo "Usage: $0 dir1 dir2 [\$pattern]"
    echo "e.g. $0 /path/to/run1 /path/to/run2"
    echo "e.g. $0 /path/to/run1 /path/to/run2 \"*.nc4\""
    exit
fi

dir1=$1
dir2=$2

first_tmp=$$.first
second_tmp=$$.second

if [[ -n $3 ]]; then
    pattern=$3
    pattern_name=$(echo $pattern | sed 's/[^a-zA-Z0-9]//g')
    outfile=check_${pattern_name}_list
    find $dir1 -type f -name "${pattern}" > $first_tmp
    find $dir2 -type f -name "${pattern}" > $second_tmp
else
    find $dir1 -type f > $first_tmp
    find $dir2 -type f > $second_tmp
    outfile=check_list
fi
[[ -e $outfile ]] && rm -rf $outfile

nfirst=$(wc -l < $first_tmp)
nsecond=$(wc -l < $second_tmp)

echo $nfirst
echo $nsecond

[[ "$nfirst" -ne "$nsecond" ]] && echo "Warning, different number of files"

if (( nfirst >= nsecond )); then
    shortlist=$second_tmp
    echo "using $dir2 contents to build pairs"
else
    shortlist=$first_tmp
    echo "using $dir1 contents to build pairs"
fi

while read line; do
    if [[ "$shortlist" == "$first_tmp" ]]; then
       tmpf=$(echo $line | sed "s|$dir1|$dir2|")
    elif [[ "$shortlist" == "$second_tmp" ]]; then
       tmpf=$(echo $line | sed "s|$dir2|$dir1|")
    fi
    echo "${line} ${tmpf}" >> $outfile
done < $shortlist

rm $first_tmp $second_tmp
