#!/bin/bash
# Size exploder
# data_file is argument 1
data_file=$1

price_fields=$2
part_fields=$3
# debug opens output in default text editor if '1' is passed as argument
debug=$4
data=data
tdir=tmp
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
	tail -n +2 < "$data_file" > $tdir/pfile.txt
	cut -d, -f $price_fields < $tdir/pfile.txt > $tdir/price-doc.txt 
	cut -d, -f $part_fields < $tdir/pfile.txt > $tdir/part-doc.txt
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
	> $tdir/dif-doc.txt
	size_line=$(head -n 1 $data_file)
	IFS=',' read -a size_array <<< $trimmed
	i=0
	dif_array=()
	# empty temp file before adding new data
	> $tdir/tmp.txt
	# check elements of givin data for conditions on which need manipulation to make output correctly formatted
	while [ "$i" -lt "${#size_array[@]}" ]; do
		ele_split[0]=$(cut -d - -f 1 <<< "${size_array[$i]}")
		ele_split[1]=$(<<< "${size_array[$i]}" rev | cut -d - -f 1 | rev )
		declare -i tmp0=$(get_index "${ele_split[0]}")
		declare -i tmp1=$(get_index "${ele_split[1]}")
		if [[ "$tmp0" -gt "$tmp1" ]]; then
			tmp2=$tmp0
			tmp0=$tmp1
			tmp1=$tmp2	
		fi
		dif=$(($tmp1 - $tmp0))
			printf $dif"," >> $tdir/dif-doc.txt
		# check elements of given data for a range to be exploded
		if [[ "${size_array[$i]}" = *-* ]]; then			
			
			if [[ "$dif" -lt 2 ]]; then
				printf "${ele_split[0]},${ele_split[1]}," >> $tdir/tmp.txt
			else
				while [ "$tmp0" -le "$tmp1" ]; do
					printf "${range_array[$tmp0]}," >> $tdir/tmp.txt
					tmp0=$(($tmp0 + 1))
				done
			fi
		else
			printf "${size_array[$i]%-*}," >> $tdir/tmp.txt			
		fi
		i=$(($i + 1))
	done
	# empty temp file before adding new data
	> $data/column_splosion.txt
	printf "part_num," > $data/column_splosion.txt
	sed -n 's/,*$//p' $tdir/tmp.txt >> $data/column_splosion.txt
	IFS=',' read -a dif_array < $tdir/dif-doc.txt
}



# if debug argument passed is 1, show the output file for whatever reason you may want to look at the file
debug() {
	if [ "$debug" -eq 1 ]
		then
		xdg-open $tdir/tmpdoc.txt
	fi
}







final() {
	i=0
	indv_part_array=()
	while read line; do
		indv_part_array[$i]=$line
		i=$(($i + 1))
	done < $data/part-doc.txt
	# value to test against for a condition when incrementing through the size group loop
	size_field_amount=$((${#size_array[@]}))
	# increments for initial loop that iterates through each individual part
	i=0; 	l=1
			#     i < 12
	# loop through each part in part array to print at the begin of each line
	while [[ "$i" -lt  "${#indv_part_array[@]}" ]]; do
		# print part at line begin
		printf "\n${indv_part_array[$i]}" >> $data/column_splosion.txt
			# assign a temporary variable the current necessary line
			line=$(sed "${l}q;d" < $tdir/price-doc.txt)
			# store each price from the line in element of tmp_price_array
			IFS=',' read -a tmp_price_array <<< $line		
			# t is the increment for 	
			t=0; 	
			# loop through size groups
			#     t < 3
			while [[ "$t" -lt "$size_field_amount" ]]; do
			
				group_price="${tmp_price_array[$t]}";
				if [[ "${dif_array[$t]}" -gt 0 ]]; then
					
					# loop through each size
					# j < 3
					j=0
					while [[ "$j" -le "${dif_array[$t]}" ]]; do
						printf ",$group_price" >> $data/column_splosion.txt
						j=$(($j + 1))
					done
				else
					printf ",$group_price" >> $data/column_splosion.txt
				fi
						
				t=$(($t + 1))
			done	
		l=$(($l + 1))
		i=$(($i + 1))
	done
	#xdg-open $data/column_splosion.txt
}

main() {
	trim_format
	explode_sizes
	final
}
main 