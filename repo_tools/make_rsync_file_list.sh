#!/bin/bash
# rsync_make_file_list.sh: Create list of files in repo for use in rsync. 
# James Polly 20250729

filelist=./repo_tools/rsync_from_files.tmp

find . -path ./.git -prune -o \
	-path ./repo_tools -prune -o \
	-type f -print > $filelist

echo $(realpath $filelist)
