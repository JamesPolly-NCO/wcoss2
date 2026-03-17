#!/bin/bash
set -ax

PDY=20260310
model="rrfs"
RUN="rrfs"
type=$model
ver=v1.0.8
envir=para

DIR=/lfs/h1/nco/ptmp/$USER/${model}.${ver}
mkdir -p $DIR

outfile=${DIR}/wtime.rtime.${type}.${PDY}

if [ -s "$outfile" ]; then 
  mv $outfile ${outfile}.hold
fi

cd  /lfs/h1/ops/$envir/output/$PDY
echo 
echo `date`
pwd
echo "Checking walltime vs runtime for $PDY $model model at /lfs/h1/ops/$envir/output/$PDY/ ..."

function sec {
  local n=$1;
  hh=`echo $n|cut -c 1-2|sed 's/^0//g'`;
  mm=`echo $n|cut -c 4-5|sed 's/^0//g'`;
  ss=`echo $n|cut -c 7-8|sed 's/^0//g'`;
  let secs=hh*60*60+mm*60+ss;
#  echo "$n  -> $hh $mm $ss  -> $secs";
  echo $secs 
}

function min {
  local n=$1;
  hh=`echo $n|cut -c 1-2|sed 's/^0//g'`;
  mm=`echo $n|cut -c 4-5|sed 's/^0//g'`;
  let mins=hh*60*60+mm*60;
#  echo "$n  -> $hh $mm $ss  -> $secs";
  echo $mins
}
#for type in $model ; do

printf "JOB,walltime,walltime(sec),runtime(min),runtime(sec),percentage\n" > $outfile;
for type in $RUN ; do
##   for cyc in 00 06 12 18 ; do
#  for cyc in {00..23} ; do
##     for file in `grep -l /packages/${model}.${ver}/ ${type}*_$cyc*.o*`; do
     for file in `grep -l /packages/${model}.${ver}/ ${type}*.o*`; do
        ecf=`grep -a " + export ECF_NAME" $file |awk -F"=" '{print $2}'|tail -1`; 
        wtime=`grep -a Resource_List.walltime $file |awk '{print $3}'`; 
        wsec=`sec $wtime`;
        wmin=`min $wtime`;
        err=$?;
            NAME=`grep -a " + export ECF_NAME=" $file|awk -F"=" '{print $2}'|tail -1`;
            rtime=`grep "$NAME " /lfs/h1/ops/$envir/com/logs/runtime/$envir/daily/$PDY.daily|awk '{print $7}'`;
            rsec=$(echo "$rtime * 60" | bc -l);
            rsec=${rsec%.*};                        # Remove decimal part
            let pcnt=$rsec*100/$wsec;
            if [ $pcnt -ge 75 ] ; then
#             echo "$ecf     $wtime   $rtime (min)/$rsec (sec)   ${pcnt}% ***";
              printf "%-85s,%-10s,%10s (sec),%10s (min),%10s (sec),%5s%% *** \n" $ecf $wtime $wmin $rtime $rsec ${pcnt} ;
            else
#             echo "$ecf     $wtime   $rtime (min)/$rsec (sec)   ${pcnt}% ";
              printf "%-85s,%-10s,%10s (sec),%10s (min),%10s (sec),%5s%% \n" $ecf $wtime $wmin $rtime $rsec ${pcnt} ;
            fi
#           echo "$ecf     $wtime   $rtime (min)   "; 
      done >> $outfile; 
      echo >> $outfile; 
      echo >> $outfile; 
  done; 
##done 
echo "Done!"
echo
echo "Check the output log file at ${outfile}..."
echo "Mailing output file."
echo
~/tools/mail.sh $outfile "${model} Job Runtimes ${PDY}"
