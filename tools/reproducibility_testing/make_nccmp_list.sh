#!/bin/bash
# make a list of nccmp commands to execute
# uses output from run_cmp_list.sh

if (($# != 1)); then
    echo "Usage: $0 \$ncext"
    echo "e.g. $0 .nc4"
    exit
fi

ncext=$1

outfile=nccmp_list
infile=cmp_list.out

if [[ ! -e $infile ]]; then
    echo "Cannot find $infile, exiting." 
    exit 0
fi 

[[ -e $outfile ]] && rm -rf $outfile

while IFS= read -r line; do
    firstfile=$(echo $line | cut -d' ' -f1)
    secondfile=$(echo $line | cut -d' ' -f2)
    echo $firstfile
    if [[ "$firstfile" == *"$ncext" ]]; then
        echo "nccmp -d -g ${firstfile} ${secondfile}" >> $outfile
        echo "echo ${firstfile}" >> $outfile
    fi
done < $infile

chmod +x $outfile
