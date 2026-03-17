#!/bin/bash
# populate_homedir.sh: Populate wcoss2 home directory with contents of repository.
# James Polly 20250729
#
# To be executed from root of "wcoss2" repo.

if [[ "/u/james.polly/repos/wcoss2" != "$(pwd)" ]]; then
    echo "Execute from root of "wcoss2" repo; exiting." 
    echo "From root of repo, try: ./repo_tools/populate_homedir.sh"
    exit 0
fi


filelist=./repo_tools/rsync_files_from.tmp
[ -a "$filelist" ] && rm $filelist

# Collect files to populate, ignoring others:
find . -path ./.git -prune -o \
	-path ./repo_tools -prune -o \
	-type f -print > $filelist

rsync -avh --files-from=$filelist ./ /u/james.polly/
rm $filelist
