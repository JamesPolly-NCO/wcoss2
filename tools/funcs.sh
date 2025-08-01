#!/bin/bash
# funcs.sh: function definitions to be sourced by multiple scripts.
# James Polly 20250731
#
# usage:
# source ~/bin/funcs.sh

function get_latest_pkg_ver {
	local model=$1
        local vdi=0
        local vdii=0
        local vdiii=0
	local tmpver
        for tmpver in $(find "/lfs/h1/ops/prod/packages" -maxdepth 1 -name "$model.*" -type d | cut -d'.' -f2-4 | cut -c2-); do
        	local tmpvernum=$(echo $tmpver | sed -e "s/_//g" -e "s/[a-zA-Z][a-zA-Z]*//g")
        	local tmpvdi=$(echo $tmpvernum | cut -d'.' -f1)
        	local tmpvdii=$(echo $tmpvernum | cut -d'.' -f2)
        	local tmpvdiii=$(echo $tmpvernum | cut -d'.' -f3)
        	[ "$tmpvdi" -gt "$vdi" ] && vdi=$tmpvdi
        	[ "$tmpvdii" -gt "$vdii" ] && vdii=$tmpvdii
        	[ "$tmpvdiii" -gt "$vdiii" ] && vdiii=$tmpvdiii
        done
        echo "v$vdi"."$vdii"."$vdiii"
}


