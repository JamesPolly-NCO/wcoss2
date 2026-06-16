#!/bin/bash
# Identify jobs using data from these packages.
# Identify files used.
#
# Desiged to be ran using upstream deps found in version/run.ver
# A separate file containing an excerpt from versions/run.ver is required.
#
# e.g. RRFS run.ver file contains the following dependencies,
# export nosofs_ver=v3.6
# export gefs_ver=v12.3
# export gfs_ver=v16.3
# export nam_ver=v4.2
# export obsproc_ver=v1.2
# export nsst_ver=v1.2
# export hrrr_ver=v4.1
# export rap_ver=v5.1
#
# Include the above information (uncommented) in a file, and pass in that 
# file's path as the fourth argument to this script.
#
# First of two scripts to be used in sequence for failure mode testing:
# 1. id_upstream_data.sh
# 2. id_upstream_subsetter.sh

if (($# != 4)); then
    echo "Usage: $0 model pdy cyc upstream_vers"
    echo "e.g. $0 rrfs 20260318 00 upstreams.ver"
    exit
fi
model=$1
pdy=$2
cyc=$3
cdate="${model}_${pdy}_${cyc}"
upstream_vers=$4

while read line; do
    updef=$(echo $line | cut -d' ' -f2)
    uppkg=$(echo $updef | cut -d '_' -f1)
    upver=$(echo $updef | cut -d '=' -f2)
    upstream=${uppkg}_${upver}

    upcom="/lfs/h1/ops/prod/com/${uppkg}/${upver}" 
    if [[ ! -e $upcom ]]; then
        echo "$upcom does not exist"
        exit
    fi

    echo "$upcom/.*" >> upstream_paths
done < $upstream_vers
echo "/lfs/h1/ops/prod/dcom/.*" >> upstream_paths

loglist="${cdate}_loglist"
outfile="${cdate}_jobs_files"
    
echo "Identifying jobs of:"
echo "$cdate"
echo "that use data from:"
cat upstream_paths

#step 1: find all job output logs containing file paths in upstream_paths
echo "Identifying logfiles containing upstream dependencies..."
if [[ -e "$loglist" ]]; then
    echo "Found existing log list: ${loglist}."
    echo "Using existing log list...Move existing log list to generate a new one."
else
    echo "No existing log list found. Querying output logs for references in file: upstream_paths."
    grep -lf  upstream_paths /lfs/h1/ops/para/output/${pdy}/${model}_*_${cyc}.o* > $loglist
fi
echo "done."

if [[ ! -s "$loglist" ]]; then
    echo "no output captured, exiting"
    rm $loglist
    exit
fi

[[ -e "$outfile" ]] && rm -rf $outfile
[[ -e "$outfile.cleaned" ]] && rm -rf $outfile.cleaned
[[ -e "$outfile.uniq" ]] && rm -rf $outfile.uniq
#[[ -e "$outfile.exists" ]] && rm -rf $outfile.exists

#step 2: for each output log file found above, get the job name and the file references:
echo "Finding upstream references in logfiles..."
njobs=$(wc -l $loglist | cut -d' ' -f1)
icnt=0
while read line; do
    if [[ "$line" == *"_${cyc}.o"* ]]; then
        tmpecfname=$(grep -ho "export ECF_NAME=.*${model}.*" $line | head -n1 | sed "s/.*j${model}/j${model}/")
        echo "$tmpecfname" >> $outfile
        grep -hof upstream_paths $line >> $outfile
        ((icnt++))
        echo -ne "Progress: $icnt / $njobs\r"
    fi
done < $loglist
[[ -e "upstream_paths" ]] && rm upstream_paths
echo "" && echo "done."

# step 2:
# requires package by package modification.
# do some cleanup on what is captured by the step 1 grep.
echo "Cleaning up (grep output) list of references..."
tmpclean=tmpfile.$$
#sed "s/' ']'//g" $outfile \
#| sed "s/]//g" \
#| sed "s/'//g" > $outfile.cleaned
tr -s ' ' '\n' < $outfile > $tmpclean
#keep first pattern (b=branch to end); delete second pattern
sed -i '/^jrrfs/b; /\/lfs\/h1\/ops\//!d' $tmpclean
sed -i "s/'$//" $tmpclean
sed -i 's/"$//' $tmpclean
sed -i 's/\/$//' $tmpclean
sed -i 's/\*$//' $tmpclean
mv $tmpclean $outfile.cleaned
echo "done."

# step 3: make file references unique for each job
echo "Making references unique for each job..."
njobs=$(grep -c '^jrrfs' $outfile.cleaned)
icnt=1
while IFS= read -r tmpjob; do
    tmpfile=$tmpjob.tmpfile
    if [[ $icnt -eq $njobs ]]; then
        sed -n "/$tmpjob/,\$ {/^jrrfs/d;p}" $outfile.cleaned > $tmpfile
    else
        sed -n "/$tmpjob/,/^jrrfs/{/^jrrfs/!p}" $outfile.cleaned > $tmpfile
    fi
    echo $tmpjob >> "$outfile.uniq"
    sort $tmpfile | uniq >> "$outfile.uniq"
    rm $tmpfile
    echo -ne "Progress: $icnt / $njobs\r"
    ((icnt++))
done < <(grep '^jrrfs' $outfile.cleaned)
echo "" && echo "done."

# step 3: check for file existence and make unique
#tmpuniqchk=tmpfile.$$
#[[ -e "$tmpuniqchk" ]] && rm $tmpuniqchk
#touch $tmpuniqchk
## check for file presence in above tmpfile before putting in .exists file.
#while read line; do
#    if [[ "$line" == *" "* ]]; then
#        for entry in $line; do
#            [[ -d "$entry" ]] && continue
#            stat $entry >/dev/null 2>&1
#            [[ $? -eq 0 ]] && echo $entry >> $tmpuniqchk
#            tmpcount=$(grep -c "$entry" $tmpuniqchk)
#            [[ $tmpcount -eq 1 ]] && echo $entry >> $outfile.exists
#        done
#    else
#        [[ -d "$line" ]] && continue
#        stat $line >/dev/null 2>&1
#        [[ $? -eq 0 ]] && echo $line >> $tmpuniqchk
#        tmpcount=$(grep -c "$line" $tmpuniqchk)
#        [[ $tmpcount -eq 1 ]] && echo $line >> $outfile.exists
#    fi
#done < $outfile.cleaned
#[[ -e "$tmpuniqchk" ]] && rm $tmpuniqchk
