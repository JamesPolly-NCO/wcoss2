#lsrunt prod /prod/primary/../gefs/v12.3/..* $pdym2 | tail -n100 | awk -f ~/tools/timecomp.awk lower_bound=2100 upper_bound=2300 | column -t
{
	begin_col = $3
	sub(":","",begin_col)
	end_col = $5
	sub(":","",end_col)
	if ( (begin_col > lower_bound) && (end_col <= upper_bound) )
		begin_hour = substr(begin_col,1,2)
		begin_minute = substr(begin_col,3,4)
		begin_time = begin_hour":"begin_minute
		end_hour = substr(end_col,1,2)
		end_minute = substr(end_col,3,4)
		end_time = end_hour":"end_minute
		print $1 " " $2 " " begin_time " " $4 " " end_time " " $6 " " $7
}



