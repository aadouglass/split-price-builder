#!/bin/bash
# Size exploder
# data_file is argument 1
data_file=$1
# array of possible sizes
ranges_array=(S M L XL 2XL 3XL 4XL 5XL 6XL 7XL 8XL)
last_element_index=$((${#ranges_array[@]}-1))
begin_range="${ranges_array[0]}"
end_range="${ranges_array[$last_element_index]}"

size_line=$(head -n 1 $data_file)

IFS=',' read -a size_array <<< $size_line



n="${ranges_array[$i]}"
end="${size_array[$i]#*-}"
i=0
l=0
while [ "$l" -lt "${#size_array[@]}" ]
do
	while [ "$i" -lt "${#ranges_array[@]}" ]
	do
		if [ "${size_array[$l]%-*}" = "$n" ]
		then
			#echo $begin
			#echo $i
			echo "${#size_array[@]}"
		fi
			if [[ "${size_array[$l]#*-}" = *-* ]]; then
				if [ "${size_array[$l]#*-}" = "$n" ]
				then
					#echo $begin
					#echo $i
					echo "${#size_array[@]}"
				fi
			fi
		
		
		#ele_range_end=${a#*-}
		#ele_range_beg=${a%-*}
		i=`expr $i + 1`
	done
	l=`expr $l + 1`
done

