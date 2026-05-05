#!/bin/bash
# Reproducibility Testing
# Unpack tarballs in COM directory

if (($# != 1)); then
    echo "Usage: $0 file_list"
    echo "e.g. $0 check_radstat_list"
    exit
fi

infile=$1
#outfile=$(pwd)/${infile}.out

[[ ! -e "$infile" ]] && echo "$infile not found, exiting." && exit 0
#[[ -e $outfile ]] && rm -rf $outfile

for i in $(cat $infile | tr ' ' '\n'); do
    tmpdir=$(dirname $i)
    cd $tmpdir
    tmpf=$(basename $i)
    #tar -xvzf $tmpf >> $outfile
    tar -xvzf $tmpf
done
