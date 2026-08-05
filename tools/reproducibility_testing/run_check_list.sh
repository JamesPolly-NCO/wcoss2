#!/bin/bash
# Reproducibility testing tool:
# Run a diffing tool on files in a list

if (($# < 2)); then
    echo "Specify command and list of file pairs [optional pattern to match]."
    echo "Usage: $0 cmd pair_list [pattern]"
    echo "e.g. $0 cmp check_list"
    echo "e.g. $0 nccmp check_cmp_list.out \"*.nc\""
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
    debufr)
        run_cmd="debufr -b"
        module load PrgEnv-intel
        module load bufr
        ;;
    gempak)
        run_cmd="diff_strings"
        diff_strings() {
            diff <(strings $1) <(strings $2)
        }
        ;;
    *)
        echo "Provided command, $1, not recognized."
        exit
        ;;
esac

infile=$2
[[ ! -e "$infile" ]] && echo "$infile not found, exiting." && exit 0

if [[ -n $3 ]]; then
    pattern=$3
    pattern_name=$(echo $pattern | sed 's/[^a-zA-Z0-9]//g')
    fprefix=${infile}_$1_${pattern_name}
else
    fprefix=${infile}_$1
fi
outfile=${fprefix}.out
donefile=${fprefix}.done
[[ ! -e "$donefile" ]] && touch $donefile

#isolate this loop in a function
while IFS= read -r line; do
    firstfile=$(echo $line | cut -d' ' -f1)
    secondfile=$(echo $line | cut -d' ' -f2)
    if [[ -n $3 && $firstfile != $pattern ]]; then
       continue
    else
        [[ $firstfile == *"dbnlog"* ]] && continue
        donecnt=$(( $(grep -c ${firstfile}$ $donefile) + $(grep -c ${secondfile}$ $donefile)))
        if [[ $donecnt -gt 0 ]]; then
            echo "Already processed $firstfile ($donecnt found)"
            continue
        fi
        echo $firstfile
        if [[ "$run_cmd" == "debufr"* ]]; then
            firstdebufrout=$(basename $firstfile).out
            $run_cmd $firstfile -o $firstdebufrout
            seconddebufrout=$(basename $secondfile).out.hold
            $run_cmd $secondfile -o $seconddebufrout
            diff $firstdebufrout $seconddebufrout >> $outfile 2>&1
            [[ $? == 1 ]] && echo $firstfile $secondfile >> $outfile
            rm $firstdebufrout $seconddebufrout
        elif [[ "$run_cmd" == "diff_strings" ]]; then
            $run_cmd $firstfile $secondfile >> $outfile 2>&1
        else
            $run_cmd $firstfile $secondfile >> $outfile 2>&1
            [[ $? == 1 ]] && [[ "$run_cmd" == "nccmp"* ]] && echo $firstfile $secondfile >> $outfile
        fi
        echo $firstfile >> $donefile
    fi
done < $infile
