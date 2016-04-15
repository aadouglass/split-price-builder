#!/bin/bash
# Size exploder
# data_file is argument 1
data_file=$1
# debug opens output in default text editor if '1' is passed as argument
debug=$2
temporary=tmp
range_array=('S' 'M' 'L' 'XL' '2XL' '3XL' '4XL' '5XL' '6XL' '7XL' '8XL')
#last_element_index=$((${#range_array[@]}-1))
#begin_range="${range_array[0]}"
#end_range="${range_array[$last_element_index]}"
#,,,,,,,L-S,XL/3XL-5XL,8XL/6XL,,, -----> S,M,L,XL,2XL,3XL,4XL,5XL,6XL,7XL,8XL


# format the data of sizes to dashed ranges for error control in manipluation of exploding ranges 
trim_format() {
	header=$(head -n 1 $data_file)
	trimmed0=$(sed -e 's/^,*//g; s/,*$//g' <<< $header)
	trimmed=$(sed 's/\//-/g' <<< $trimmed0)
}



get_index() {
	# pass the size as the first argument to be compared to range_array and return its index for arithmetic
	value=$1
	for i in "${!range_array[@]}"; do
	   if [[ "${range_array[$i]}" = "${value}" ]]; then
	       echo "${i}";
	   fi
	done
}



explode_sizes() {
	# extract sizes for manipulation
	size_line=$(head -n 1 $data_file)
	IFS=',' read -a size_array <<< $trimmed
	i=0
	# empty temp file before adding new data
	> $temporary/tmp.txt
	# check elements of givin data for conditions on which need manipulation to make output corerectly formatted
	while [ "$i" -lt "${#size_array[@]}" ]; do
		ele_split[0]=$(cut -d - -f 1 <<< "${size_array[$i]}")
		ele_split[1]=$(<<< "${size_array[$i]}" rev | cut -d - -f 1 | rev )
		declare -i tmp0=$(get_index "${ele_split[0]}")
		declare -i tmp1=$(get_index "${ele_split[1]}")
		if [[ "$tmp0" -gt "$tmp1" ]]; then
			echo $tmp0 $tmp1
			tmp2=$tmp0
			tmp0=$tmp1
			tmp1=$tmp2
			echo $tmp0 $tmp1	
		fi
		# check elements of given data for a range to be exploded
		if [[ "${size_array[$i]}" = *-* ]]; then			
			dif=$(($tmp1 - $tmp0))
			if [[ "$dif" -lt 2 ]]; then
				printf "${ele_split[0]},${ele_split[1]}," >> $temporary/tmp.txt
			else
				while [ "$tmp0" -le "$tmp1" ]; do
					printf "${range_array[$tmp0]}," >> $temporary/tmp.txt
					tmp0=$(($tmp0 + 1))
				done
			fi
		else
			printf "${size_array[$i]%-*}," >> $temporary/tmp.txt			
		fi
		i=$(($i + 1))
	done
	# empty temp file before adding new data
	> $temporary/tmpdoc.txt
	sed -n 's/,*$//p' $temporary/tmp.txt >> $temporary/tmpdoc.txt	
}


# if debug argument passed is 1, show the output file for whatever reason you may want to look at the file
debug() {
	if [ "$debug" -eq 1 ]
		then
		xdg-open $temporary/tmpdoc.txt
	fi
}



main() {
	trim_format
	explode_sizes
	debug
}
main