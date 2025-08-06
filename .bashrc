set -o vi

module use /apps/ops/para/nco/modulefiles/core

localnoscrub=$(ls -l /lfs/h1/nco/idsb/noscrub \
	| grep -i 'james.polly' \
	| grep 'james.polly ..*idsb' \
	| cut -d' ' -f15)

pdy=$(date "+%Y%m%d")
pdym1=$(date "+%Y%m%d" -d "$pdy - 1 day")
pdym2=$(date "+%Y%m%d" -d "$pdy - 2 day")
pdym3=$(date "+%Y%m%d" -d "$pdy - 3 day")
pdym4=$(date "+%Y%m%d" -d "$pdy - 4 day")
pdym5=$(date "+%Y%m%d" -d "$pdy - 5 day")
pdym6=$(date "+%Y%m%d" -d "$pdy - 6 day")
pdym7=$(date "+%Y%m%d" -d "$pdy - 7 day")

alias editspalog="/lfs/h1/ops/prod/logs/editspalog"
alias viewspalog="view /lfs/h1/ops/prod/logs/spalog"
alias ecflowincludes="echo /apps/ops/prod/nco/core/ecflow.v5.6.0.14/include/"
alias wcoss2notes="vi /lfs/h1/nco/idsb/noscrub/$localnoscrub/notes/wcoss2.txt"
alias dbnet_siphonlog="echo /lfs/h1/ops/prod/dbnet_siphon/log/dbnet.log.$pdy"

alias gd="pushd"
alias pd="popd"
alias dirs="dirs -v"

alias lld="ls -lda"

prodpackage="/lfs/h1/ops/prod/packages"
parapackage="/lfs/h1/ops/para/packages"

qcd () {
	# accept 1 argument that is a string key, and perform a different
	# "pushd" operation for each key
	case "$1" in
		ptmp)
			pushd /lfs/h1/nco/ptmp/james.polly/
			;;
		noscrub)
			pushd /lfs/h1/nco/idsb/noscrub/$localnoscrub
			;;
		longrun)
		        pushd /lfs/h1/ops/test/com/logs/runtime/test/longrun
			;;
		prodoutput)
                        pushd /lfs/h1/ops/prod/output/$pdy
			;;
		paraoutput)
                        pushd /lfs/h1/ops/para/output/$pdy
			;;
		testoutput)
                        pushd /lfs/h1/ops/test/output/$pdy
			;;
		prodcom)
			pushd /lfs/h1/ops/prod/com
			;;
		paracom)
			pushd /lfs/h1/ops/para/com
			;;
		testcom)
			pushd /lfs/h1/ops/test/com
			;;
		prodpackage)
			pushd /lfs/h1/ops/prod/packages
			;;
		parapackage)
			pushd /lfs/h1/ops/para/packages
			;;
		testpackage)
			pushd /lfs/h1/ops/test/packages
			;;
		prodruntime)
			pushd /lfs/h1/ops/prod/com/logs/runtime/prod/daily
			;;
		pararuntime)
			pushd /lfs/h1/ops/para/com/logs/runtime/para/daily
			;;
		rrfshome)
			pushd /lfs/h2/emc/lam/noscrub/emc.lam/rrfs/para/packages/rrfs.v1.0.0
			;;
		rrfscom)
			pushd /lfs/h3/emc/lam/noscrub/ecflow/ptmp/emc.lam/ecflow_rrfs/para/com/rrfs/v1.0
			;;
		rrfsjoblog)
			pushd /lfs/h3/emc/lam/noscrub/ecflow/ptmp/emc.lam/ecflow_rrfs/para/output/prod/today
			;;
		*)
			#supplied arg not supported
			echo "qcd: unknown key '$1'"
			return 1
			;;
	esac
}
complete -W "noscrub longrun prodoutput paraoutput testoutput prodcom paracom testcom prodpackage parapackage testpackage prodruntime pararuntime rrfscom rrfshome rrfsjoblog" qcd

lsrunt () {
          # Get info from:
          # /lfs/h1/ops/para/com/logs/runtime/para/daily 
          # using, e.g.:
          # grep "/para/primary/cron/satingest" $pdym1.daily | sort -k3 | head | column -t
          case "$1" in
		  para)
			  tmpenvir="para"
			  ;;
		  prod)
			  tmpenvir="prod"
			  ;;
		  help)
			  #output help info and exit
			  echo "usage: lsrunt <ENVIR> <QUERY> <YYYYMMDD>"
			  echo " e.g.: lsrunt prod "/para/primary/cron/satingest" $pdy"
			  echo "Note: <QUERY> will respect grep regex, e.g.: .* for character wildcard."
			  return 0
			  ;;
		  *)
			  #supplied arg not supported
			  echo "lsrunt: unknown key '$1'"
			  return 1
			  ;;
	  esac
	  echo "searching /lfs/h1/ops/$1/com/logs/runtime/$1/daily/$3.daily"
          echo "grep '$2' /lfs/h1/ops/$1/com/logs/runtime/$1/daily/$3.daily | column -t"
          grep $2 /lfs/h1/ops/$1/com/logs/runtime/$1/daily/$3.daily | column -t
  }

lmodload () {
	case "$1" in
		depsdotpy)
			module unload python
			module use /apps/ops/para/nco/modulefiles/core
			module load prod_util intel python/3.8.6 deps
			;;
		python)
			module unload python
			module load intel/19.1.3.304
			module load python/3.12.0
			;;
		wgrib)
			module load intel/19.1.3.304
			module load libjpeg
			module load grib_util
			;;
		wgrib2)
			module load intel/19.1.3.304
			module load wgrib2
			;;
		help)
			echo "usage: lmodload <ARGNAME>"
			echo "e.g.: lmodload python"
			return 0
			;;
		*)
			echo "lmodload: unknown key '$1'"
			return 1
			;;
	esac
}

# TODO: add completion functionality for programs e.g.
# https://www.gnu.org/software/bash/manual/html_node/A-Programmable-Completion-Example.html
# TODO: function to pull the output files for a job from runtimes log
