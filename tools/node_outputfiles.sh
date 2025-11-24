node=${1:?"arg1 should be node to check"}
date=${2:?"arg2 should be date"}

if [[ -r /sfs/pbs/$node/mom_logs/$date ]]; then
 MOM_LOG=/sfs/pbs/$node/mom_logs/$date
else
 MOM_LOGS_TMPDIR=/lfs/h1/nco/ptmp/$USER/pbs/$node/mom_logs
 mkdir -p $MOM_LOGS_TMPDIR
 scp -p $node:/var/spool/pbs/mom_logs/$date $MOM_LOGS_TMPDIR
 scp_err=$?
 if [[ $scp_err -ne 0 ]]; then
   echo "scp failed.  get state from pbsnodes command"
   pbsnodes $node | grep state
#  if [[ "$USER" != ops.prod ]]; then
#    echo "scp failed.  try as ops.prod."
#  fi
   exit 1
 fi
 MOM_LOG=$MOM_LOGS_TMPDIR/$date
fi

datem1=$(date --date="$date -u -1 day" +%Y%m%d)
datem2=$(date --date="$date -u -2 day" +%Y%m%d)
datem3=$(date --date="$date -u -3 day" +%Y%m%d)
datem4=$(date --date="$date -u -4 day" +%Y%m%d)
for id in $(grep "job ID is" $MOM_LOG | grep begin | awk '{print $10}' | cut -f 1 -d .); do 
   for envir in para prod test; do 
     ls -l /lfs/h1/ops/$envir/output/$date/*.o$id 2>/dev/null
   done
done | column -t | more

