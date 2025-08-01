if (($# != 2)); then
	echo "usage: $0 /path/to/attachment/file "Email Subject Line""
	exit
fi

contents="See attached"
mail -s "$2" -a $1 James.Polly@noaa.gov <<< "$contents"
