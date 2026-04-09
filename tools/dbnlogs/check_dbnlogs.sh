#!/bin/bash
# Check that all dbnlog entries contain five things:
# [TIME] [TYPE] [SUBTYPE] [JOBID] [FILENAME]
#        ^ Latter four entries are args provided to dbn_alert.
#
# Use below example to find directory names to provide as arguments to this script:
#
# find /lfs/h1/ops/para/com/rrfs/v1.0/*.20260407/ -type d -name "*dbnlogs"


if (($# != 1)); then
    echo "Usage: $0 \$dbnlogdir"
    echo "e.g. $0 /lfs/h1/ops/para/com/rrfs/v1.0/rrfs.20260408/dbnlogs"
    exit
fi

dbnlogdir=$1
outfile=$(basename $(dirname $1)).dbnlog.bad

[[ -e "$outfile" ]] && rm -rf $outfile

for tmplog in $(find $1 -type f); do
    col_width=$(awk '{print NF}' $tmplog)
    num_col_widths=$(echo $col_width | tr ' ' '\n' | sort | uniq | wc -l)
    if (( num_col_widths != 1 )); then
        echo $tmplog >> $outfile
        echo "Fail: Number of fields provided to dbnalert is not consistent." >> $outfile
    else
        max_col_width=$(echo $col_width | tr ' ' '\n' | sort -r | uniq | head -n1)
        if (( max_col_width != 5 )); then
            echo $tmplog >> $outfile
            echo "Fail: Number of fields provided to dbnalert is not four." >> $outfile
        fi
    fi
done

[[ ! -e "$outfile" ]] && echo "$1 logs are OK." && touch $(basename $(dirname $1)).dbnlog.OK
