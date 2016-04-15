#!/bin/bash
# Size exploder
# data_file is argument 1
data_file=$1
# array of possible sizes
range_array=('S' 'M' 'L' 'XL' '2XL' '3XL' '4XL' '5XL' '6XL' '7XL' '8XL')
last_element_index=$((${#range_array[@]}-1))
begin_range="${range_array[0]}"
end_range="${range_array[$last_element_index]}"



trim_format() {
	header=$(head -n 1 $data_file)
	trimmed=$(sed 's/\//-/g' <<< $header)
}



get_index() {
	value=$1

	for i in "${!range_array[@]}"; do
	   if [[ "${range_array[$i]}" = "${value}" ]]; then
	       echo "${i}";
	   fi
	done
}



explode_sizes() {
	size_line=$(head -n 1 $data_file)
	IFS=',' read -a size_array <<< $trimmed
	i=0
	> tmp/tmp.txt
	while [ "$i" -lt "${#size_array[@]}" ]; do		
		if [[ "${size_array[$i]}" = *-* ]]; then
			ele_split[0]=$(cut -d - -f 1 <<< "${size_array[$i]}")
			ele_split[1]=$(<<< "${size_array[$i]}" rev | cut -d - -f 1 | rev )	
			declare -i tmp0=$(get_index "${ele_split[0]}")
			declare -i tmp1=$(get_index "${ele_split[1]}")			
			dif=$(($tmp1 - $tmp0))
			if [[ "$dif" -lt 2 ]]; then
				printf "${ele_split[0]},${ele_split[1]}," >> tmp/tmp.txt
			else
				while [ "$tmp0" -le "$tmp1" ]; do
					printf "${range_array[$tmp0]}," >> tmp/tmp.txt
					tmp0=$(($tmp0 + 1))
				done
			fi
		else
			printf "${size_array[$i]%-*}," >> tmp/tmp.txt			
		fi
		i=$(($i + 1))
	done
	> tmp/tmpdoc.txt
	sed -n 's/,*$//p' tmp/tmp.txt >> tmp/tmpdoc.txt
	xdg-open tmp/tmpdoc.txt
}







main() {
	trim_format
	explode_sizes
}
main