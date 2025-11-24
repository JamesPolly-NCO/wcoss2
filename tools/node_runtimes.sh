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
   echo "scp failed.  get state of $node from pbsnodes command"
   pbsnodes $node | grep state
#  if [[ "$USER" != ops.prod ]]; then
#    echo "scp failed.  try as ops.prod."
#  fi
   exit 1
 fi
 MOM_LOG=$MOM_LOGS_TMPDIR/$date
fi

datep1=$(date --date="$date -u +1 day" +%Y%m%d)
datem1=$(date --date="$date -u -1 day" +%Y%m%d)
datem2=$(date --date="$date -u -2 day" +%Y%m%d)
datem3=$(date --date="$date -u -3 day" +%Y%m%d)
datem4=$(date --date="$date -u -4 day" +%Y%m%d)
for id in $(grep "job ID is" $MOM_LOG | grep begin | awk '{print $10}' | cut -f 1 -d .); do 
   echo --------------  $id -----------------
   for envir in para prod; do 
#     nfiles=$(ls -1 /lfs/h1/ops/$envir/output/$date/*.o$id 2>/dev/null | egrep -v "/(madis|.*datachk|mag|swmf|nwm|hwm|radarl2|runtime)" | wc -l)
     nfiles=$(ls -1 /lfs/h1/ops/$envir/output/$date/*.o$id 2>/dev/null | egrep -v "/(madis|.*datachk|mag|swmf|hwm|radarl2|runtime|wtcm_ondemand)" | wc -l)
     RUNTIME_LOGS=/lfs/h1/ops/$envir/com/logs/runtime/$envir/daily
     if [ $nfiles -eq 1 ]; then 
        file=/lfs/h1/ops/$envir/output/$date/*.o$id
        grep ^Job.*nid $file
        ECF_NAME=$(grep "export ECF_NAME=" $file|head -1| cut -f 2 -d=)
        grep "$ECF_NAME " $RUNTIME_LOGS/{$datem4,$datem3,$datem2,$datem1,$date}.daily
        [[ -e $RUNTIME_LOGS/$datep1.daily ]] && grep -H "$ECF_NAME $date" $RUNTIME_LOGS/$datep1.daily
        ls -l $file
        grep "walltime.*exceeded" $file | sed -e "s/wall/******************************************************************************************************* wall/"
     fi
   done
done | more

