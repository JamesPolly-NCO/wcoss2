#!/bin/bash
#!/bin/bash
# Make the transfer parm list files for the test suite transfer family of jobs:
# /test/primary/cron/transfer/v2.4/wcoss_1/rrfs/stage_test/enkf_restart/rrfs_{1..6}

if (($# != 1)); then
    echo "usage: $0 CYC"
    echo "e.g. $0 06"
    echo "Where CYC is a two-digit number between 00 and 23"
    exit
fi

CYC=$1
m1cycs=(23 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22)
cycm1=${m1cycs[10#$CYC]}


bigcycs=(00 00 00 00 00 00 06 06 06 06 06 06 12 12 12 12 12 12 18 18 18 18 18 18)
bigcycm1=${bigcycs[10#$cycm1]}

echo "# This file specifies the directories to be transfered and, optionally, the files within
# those directories to include or exclude.  If one directory is specified per line, it
# will be used as both the source and destination.  If two directories are specified per
# line, separated by one or more spaces, the first will be used as the source and the
# second the destination.  Directories that begin with \"com/\" will be resolved using
# the compath.py utility.  Rules may be placed below each directory or directory pair
# and must begin with one of the following characters:
#  -  exclude, specifies an exclude pattern
#  +  include, specifies an include pattern
#  .  merge, specifies a merge-file to read for more rules
#  :  dir-merge, specifies a per-directory merge-file
#  H  hide, specifies a pattern for hiding files from the transfer
#  S  show, files that match the pattern are not hidden
#  P  protect, specifies a pattern for protecting files from deletion
#  R  risk, files that match the pattern are not protected
#  !  clear, clears the current include/exclude list (takes no arg)
#  B  bytes, relative size of the path in relation to the other paths in the list
#  D  delete, delete extraneous files from destination directories (takes no arg)
#  E  encrypt, enables data encryption [two cores should be allocated] (takes no arg)
#  T  two-way syncronization will update both sides with latest changes (takes no arg)
#  Z  compress data as it is sent, accepts optional compression level argument (1-9)
# Rules higher in the list take precedence over lower ones.  By default, all files in a
# directory are included, so if no exclude patterns match that file, it will be
# transfered.
" > preamble.tmp

memnums=(001 002 003 004 005 006 007 008 009 010\
         011 012 013 014 015 016 017 018 019 020\
         021 022 023 024 025 026 027 028 029 030)

for i in $(seq 1 6); do
    outfile=transfer_rrfs_stage_test_enkf_restart_${i}.list
    cat preamble.tmp > $outfile

    fivei=$((i * 5))
    tmpmems=(${memnums[$((fivei - 5))]}\
             ${memnums[$((fivei - 4))]}\
             ${memnums[$((fivei - 3))]}\
             ${memnums[$((fivei - 2))]}\
             ${memnums[$((fivei - 1))]})
    
    echo "/lfs/h1/ops/para/com/rrfs/v1.0/enkfrrfs._PDY_/ _COMROOT_/rrfs/_SHORTVER_/enkfrrfs._PDY_/
+ /${bigcycm1}/
+ /${bigcycm1}/m???/
+ /${bigcycm1}/m???/lbcs/
+ /${bigcycm1}/m${tmpmems[0]}/lbcs/gfs_bndy.*
+ /${bigcycm1}/m${tmpmems[1]}/lbcs/gfs_bndy.*
+ /${bigcycm1}/m${tmpmems[2]}/lbcs/gfs_bndy.*
+ /${bigcycm1}/m${tmpmems[3]}/lbcs/gfs_bndy.*
+ /${bigcycm1}/m${tmpmems[4]}/lbcs/gfs_bndy.*" >> $outfile
    
    if [[ "0719" == *"$cycm1"* ]]; then 
        echo "+ /${cycm1}_spinup/
+ /${cycm1}_spinup/m???/
+ /${cycm1}_spinup/m???/forecast/
+ /${cycm1}_spinup/m???/forecast/INPUT
+ /${cycm1}_spinup/m${tmpmems[0]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}_spinup/m${tmpmems[1]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}_spinup/m${tmpmems[2]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}_spinup/m${tmpmems[3]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}_spinup/m${tmpmems[4]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}_spinup/m???/forecast/RESTART/
+ /${cycm1}_spinup/m${tmpmems[0]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}_spinup/m${tmpmems[1]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}_spinup/m${tmpmems[2]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}_spinup/m${tmpmems[3]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}_spinup/m${tmpmems[4]}/forecast/RESTART/*.${CYC}0000.*" >> $outfile
    else
        echo "+ /${cycm1}/
+ /${cycm1}/m???/
+ /${cycm1}/m???/forecast/
+ /${cycm1}/m???/forecast/INPUT
+ /${cycm1}/m${tmpmems[0]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}/m${tmpmems[1]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}/m${tmpmems[2]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}/m${tmpmems[3]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}/m${tmpmems[4]}/forecast/INPUT/gfs_ctrl.nc
+ /${cycm1}/m???/forecast/RESTART/
+ /${cycm1}/m${tmpmems[0]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}/m${tmpmems[1]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}/m${tmpmems[2]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}/m${tmpmems[3]}/forecast/RESTART/*.${CYC}0000.*
+ /${cycm1}/m${tmpmems[4]}/forecast/RESTART/*.${CYC}0000.*" >> $outfile
    fi
echo "- *
B 1000000" >> $outfile
done

rm preamble.tmp
