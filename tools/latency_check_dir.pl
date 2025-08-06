#!/usr/bin/perl -I/usr/lib/perl5
##!/usr/bin/perl -I/usr/lib/perl5/5.10.0
##!/usr/bin/perl -I/usr/lib/perl5/5.26.1

# Check transfer latency between production and backup systems.
#
# Usage:
# latency_check_dir.pl /dir/path/containing/files/to/check
# e.g. latency_check_dir.pl /lfs/h1/ops/prod/com/rtofs/v2.4/rtofs.20250725/
#
# Original per Justin Cooke by way of Simon Hsiao.
#
# Minor changes made by James Polly:
# 2025-07-25: Print latency for all files.
#
# TODO: clean up commented out code, revisit decisions, helpful comments, shebangs...

#use Time::CTime;
#use Time::gmtime;
use File::Find;

use POSIX qw(strftime);

$dir=$ARGV[0];
$latency_min=0;
# Only look for data placed in the last 15 mins
# $change_time=time()-900;
# 15 minute threshold between ctime and mtime
# $change_time=900;

$check_time=180;

@files=();
find(sub { push @files, $File::Find::name; }, "$dir");

printf "checking dir latency %s > %d (sec) \n\n", $dir, $check_time;

foreach $key (@files)
   {

      #Only look if data is a file
      if ( -d $key ) {next}

      #Get stat info
      ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat "$key";
 
      $mtm=strftime("%Y-%m-%d-%H-%M-%S",localtime($mtime));
      $ctm=strftime("%Y-%m-%d-%H-%M-%S",localtime($ctime));
      $atm=strftime("%Y-%m-%d-%H-%M-%S",localtime($atime));

      $latency_sec=($ctime-$mtime);
#      if ( $latency_sec < $check_time ) {next}

#      #Check against recent change time
#      if ( $ctime < $change_time ) {next}

      $latency_min=($ctime-$mtime)/60;

      printf "%s  %d (min)\n", $key, $latency_min;

      #Determine the maximum delay
      if ($latency_min > $max_latency) {
         $max_latency=$latency_min;
         $max_file=$key;
      } 
}

printf "\n%d (min) maximum latency for file:\n", $max_latency;
printf "%s\n", $max_file;
exit 0;
