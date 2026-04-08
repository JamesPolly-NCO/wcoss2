#!/bin/bash
# make a list of nccmp commands to execute
# uses output from run_cmp_list.sh

if (($# != 0)); then
    echo "Usage: $0 "
    echo "Do not provide any args."
    exit
fi

outfile=ncdumpdiff_list
infile=cmp_list.out

if [[ ! -e $infile ]]; then
    echo "Cannot find $infile, exiting." 
    exit 0
fi 

[[ -e $outfile ]] && rm -rf $outfile

while IFS= read -r line; do
    firstfile=$(echo $line | cut -d' ' -f1)
    secondfile=$(echo $line | cut -d' ' -f2)
    echo "diff <(ncdump -h ${firstfile}) <(ncdump -h ${secondfile})" >> $outfile
done < $infile

chmod +x $outfile
