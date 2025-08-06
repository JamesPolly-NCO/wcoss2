#!/bin/bash
# check_triggers.sh: Script to identify existing triggers in production ecflow definitions.
# Originally written by Simon Hsiao, adapted/stolen/now by:
# James Polly 20250806
#
# See usage below:

if (($# != 5 )); then
	echo "Error: five arguments needed: CYC MODEL OLD_VER HOST PORT"
	echo "usage:"
	echo "     check_trigger.sh 06 rtofs v2.4 decflow0? 31415"
	exit
fi
             # e.g.:
cyc=$1       # 00          #12         #cron
model=$2     # rtofs      #obsproc     #gfs
old_ver=$3   # v1.1       #v1.0        #v16.2
host=$4      # decflow01  #cecflow02
port=$5      # 31415      # 14142

awkfile="$HOME"/tools/getnodepath.awk

rm  ./def.${cyc} 

module load intel
module load ecflow

echo host=$host  port=$port   sleep 2 sec
sleep 2
ecflow_client --host=$host --port=$port --get /prod/primary/${cyc}> def.${cyc}
cat def.${cyc}  | awk -f $awkfile | grep "$model\/$old_ver" | grep -v "^/${cyc}/$model/"
