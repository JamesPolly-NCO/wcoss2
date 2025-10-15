#!/bin/bash
# ecf_job_script_calls.sh: Follows sequence of nested calls from ecf files, j-jobs, and exscripts.
# James Polly 20250806
#
# See usage below:

if (($# != 1 )); then
	echo "Error: one argument needed: .ecf file path."
	echo "usage:"
	echo "     $0 /abs/path/to/file.ecf"
	exit
fi

scratch="$HOME"/scratch

tmpjobs="$scratch"/jobs.out
rm -f $tmpjobs

tmpscripts="$scratch"/scripts.out
rm -f $tmpscripts

tmpnames="$scratch"/names.out
rm -f $tmpnames

fecf=$1
grep -ho 'jobs\/J.*' $fecf > $tmpjobs
grep 'PBS -N ' $fecf | sed 's/..*PBS -N //' | sed 's/#..*//' >> $tmpnames

for jtmp in $(< $tmpjobs); do 
	grep -ho 'scripts\/ex.*' $jtmp >> $tmpscripts
done

paste $tmpjobs $tmpscripts $tmpnames | column -t

