#!/bin/bash
# diff_checks.sh: compare the files in the repo with their "in-use" counterparts.
# James Polly 20250808

for tmpf in $(find $HOME/repos/wcoss2 -path $HOME/repos/wcoss2/.git -prune -o\
	                              -path $HOME/repos/wcoss2/repo_tools -prune -o\
				      -type f -print); do
	reltmpf=$(echo $tmpf | sed "s|$HOME\/repos\/wcoss2\/||")
	echo $reltmpf
	diff $HOME/repos/wcoss2/$reltmpf $HOME/$reltmpf
done
