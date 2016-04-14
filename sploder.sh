#!/bin/bash
# Size exploder
# data_file is argument 1
data_file=$1
# array of possible sizes
range_array=('S' 'M' 'L' 'XL' '2XL' '3XL' '4XL' '5XL' '6XL' '7XL' '8XL')
last_element_index=$((${#range_array[@]}-1))
begin_range="${range_array[0]}"
end_range="${range_array[$last_element_index]}"

size_line=$(head -n 1 $data_file)

IFS=',' read -a size_array <<< $size_line

#l=0
#while [ "$l" -lt "${#size_array[@]}" ]
#do
#	i=0
#	while [ "$i" -lt "${#ranges_array[@]}" ]
#	do
#		if [ "${size_array[$l]%-*}" = "${ranges_array[$i]}" ]
#		then
#			temp_var=${size_array[$l]%-*}
#		fi
#	
#		t=0
#		if [[ "${size_array[$l]}" = *-* ]]
#		then
#			while [ "$t" -lt "${#ranges_array[@]}" ]	
#			do
#				if [ "${size_array[$t]#*-}" = "${ranges_array[$i]}" ]
#				then
#					tmp_var=${size_array[$l]#*-}
#					echo "$temp_var-$tmp_var"
#				fi
#				t=`expr $t + 1`
#			done
#	fi
#		
#		
#		#ele_range_end=${a#*-}
#		#ele_range_beg=${a%-*}
#
#		i=`expr $i + 1`
#	done
#	l=`expr $l + 1`
#done


get_index() {
	value=$1

	for i in "${!range_array[@]}"; do
	   if [[ "${range_array[$i]}" = "${value}" ]]; then
	       echo "${i}";
	   fi
	done
}
array=(2XL 3XL 4XL)


var=$(get_index "${array[1]}")









function1() {
	i=0
	> tmp.txt
	while [ "$i" -lt "${#size_array[@]}" ]; do
		n=$(($i+1))
		ele_split=(${size_array[$i]%-*} ${size_array[$i]#*-})
		
		if [[ "${size_array[$i]}" = *-* ]]; then
			declare -i tmp0=$(get_index "${ele_split[0]}")
			declare -i tmp1=$(get_index "${ele_split[1]}")
			dif=$(($tmp1 - $tmp0))
			if [[ "$dif" -lt 2 ]]; then
				printf "${size_array[$i]%-*},${size_array[$i]#*-}," >> tmp.txt
			else
				tmp2=$((tmp1+1))
				while [ "$tmp0" -lt "$tmp2" ]; do
					printf "${range_array[$tmp0]}," >> tmp.txt
					tmp0=$(($tmp0+1))
				done
			fi
		else
			printf "${size_array[$i]%-*}," >> tmp.txt			
		fi
		i=$(($i + 1))
	done
	xdg-open tmp.txt
}
function1


