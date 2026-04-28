#!/bin/bash
# Reproducibility testing tool:
# Run a diffing tool on files in a list

if (($# != 2)); then
    echo "Specify command and list of file pairs."
    echo "Usage: $0 cmd pair_list"
    echo "e.g. $0 cmp check_list"
    echo "e.g. $0 nccmp check_nc4_list"
    exit
fi

#check that command is valid:
case "$1" in
    cmp)
        run_cmd="cmp"
        ;;
    nccmp)
        run_cmd="nccmp -d -g"
        module load PrgEnv-intel
        module load netcdf
        module load nccmp
        ;;
    *)
        echo "Provided command, $1, not recognized."
        exit
        ;;
esac

infile=$2
outfile=${infile}_$1.out
donefile=${infile}.done

[[ ! -e "$infile" ]] && echo "$infile not found, exiting." && exit 0
[[ ! -e "$donefile" ]] && touch $donefile

#isolate this loop in a function
while IFS= read -r line; do
    firstfile=$(echo $line | cut -d' ' -f1)
    secondfile=$(echo $line | cut -d' ' -f2)
    donecnt=$(( $(grep -c ${firstfile}$ $donefile) + $(grep -c ${secondfile}$ $donefile)))
    if [[ $donecnt -gt 0 ]]; then
        echo "Already processed $firstfile ($donecnt found)"
        continue
    fi
    echo $firstfile
    $run_cmd $firstfile $secondfile >> $outfile 2>&1
    echo $firstfile >> $donefile
done < $infile
