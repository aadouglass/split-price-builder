#!/bin/bash
# export 'PS4=\e[1;34m+ ${FUNCNAME:-main}@\e[1;36m${BASH_SOURCE}: \e[0;32m${LINENO}->  \e[0m'
# > error_log/price-builder-error-log.txt
# set -o xtrace > error_log/price-builder-error-log.txt
# rm $tdir/*
data=data

tdir=tmp
# give me the path to the file of data
price_part_file=$1
# if the columns need exploding use '0' if not, enter '1'
need_splodin=$2
if [[ "$2" = 0 ]]; then
	reused_datafile="data/column_splosion.csv"
elif [[ "$2" = 1 ]]; then
	reused_datafile="$1"
fi
# enter the range of fields/columns that the sizes/prices span
price_size_fields=$3
# what field/column are the parts located
part_fields=$4
# what line are the sizes locatated
size_line=$5
# debug clears tmp directory on passing of '1', opens output in default text editor if '2' is passed as argument and anything else exits debug.
debug=$6


range_array=('S' 'M' 'L' 'XL' '2XL' '3XL' '4XL' '5XL' '6XL' '7XL' '8XL')




# format the data of sizes to dashed ranges for error control in manipluation of exploding ranges
# clean the variable with sizes by clearing white space
trim_format() {


	#### sploder.sh
	header=$(head -n 1 $price_part_file)
	trimmed0=$(sed -e 's/^,*//g; s/,*$//g' <<< $header)
	trimmed=$(sed 's/\//-/g' <<< $trimmed0)
	tail -n +2 < $price_part_file > $tdir/pfile.txt
	cut -d, -f $price_size_fields < $tdir/pfile.txt > $tdir/price-doc.txt
	cut -d, -f $part_fields < $tdir/pfile.txt > $tdir/part-doc.txt
}

retrim() {
	temp_sizes=$(sed -n "${size_line}p" < $reused_datafile)
	sizes=$(sed -e 's/^,*//g; s/,*$//g; s/ //g' <<< $temp_sizes)
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
	> $tdir/recalculation.txt
	#########################################################size_line=$(head -n 1 $price_part_file)
	IFS=',' read -a size_array <<< $trimmed
	i=0
	dif_array=()
	# empty temp file before adding new data
	> $tdir/tmp.txt
	# check elements of givin data for conditions on which need manipulation to make output correctly formatted
	while [ "$i" -lt "${#size_array[@]}" ]; do
		ele_split[0]=$(cut -d - -f 1 <<< "${size_array[$i]}")
		ele_split[1]=$(<<< "${size_array[$i]}" rev | cut -d - -f 1 | rev )
		declare -i tmp0=$(get_index "${ele_split[0]^^}")
		declare -i tmp1=$(get_index "${ele_split[1]^^}")
		if [[ "$tmp0" -gt "$tmp1" ]]; then
			tmp2=$tmp0
			tmp0=$tmp1
			tmp1=$tmp2	
		fi
		dif=$(($tmp1 - $tmp0))
		field_range_recalc=$(($dif + 1))
		printf "$field_range_recalc\n" >> $tdir/recalculation.txt
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
	> $data/column_splosion.csv
	printf "," > $data/column_splosion.csv
	sed -n 's/,*$//p' $tdir/tmp.txt >> $data/column_splosion.csv
	IFS=',' read -a dif_array < $tdir/dif-doc.txt
}


final_splosion() {
	i=0
	indv_part_array=()
	while read line; do
		indv_part_array[$i]=$line
		i=$(($i + 1))
	done < $tdir/part-doc.txt
	# value to test against for a condition when incrementing through the size group loop
	size_field_amount=$((${#size_array[@]}))
	# increments for initial loop that iterates through each individual part
	i=0; 	l=1
			#     i < 12
	# loop through each part in part array to print at the begin of each line
	while [[ "$i" -lt  "${#indv_part_array[@]}" ]]; do
		# print part at line begin
		printf "\n${indv_part_array[$i]}" >> $data/column_splosion.csv
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
						printf ",$group_price" >> $data/column_splosion.csv
						j=$(($j + 1))
					done
				else
					printf ",$group_price" >> $data/column_splosion.csv
				fi
						
				t=$(($t + 1))
			done	
		l=$(($l + 1))
		i=$(($i + 1))
	done
}

# Splits each row of a document into an element of row_array for easier manipulation
split_lines() {
	i=0
	row_array=()
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
		# print value to file for checking if errors exist
		printf %s "${row_array[*]}" > $tdir/input-file-rows.txt
		i=`expr $i + 1`
		# finished using price_part_file		
	done < $reused_datafile
}


# Sizes are extracted to create SKU permutations in later function
get_sizes() {
	size_array=()
	IFS=',' read -a size_array <<< $sizes
	# print value to file for checking if errors exist
	printf %s "${size_array[*]}" > $tdir/input-file-sizes.txt
}

# Extract all part numbers from given file to later create permutations of the numbers with sizes
get_parts() {
	temp_part=()
	parts_array=()
	# 
	temp_part=$(cut -d, -f 1 $reused_datafile)
	# print value to file for checking if errors exist and to manipulate data further
	printf %s "${temp_part[*]}" > $tdir/input-file-parts.txt
	sed -i -e '$a\' $tdir/input-file-parts.txt
	i=0
	while IFS='\n' read -a another_array
	do
		parts_array[$i]="${another_array[@]}"
		printf %s "${parts_array[*]}" > $tdir/output-file-parts.txt
		i=`expr $i + 1`
	done < $tdir/input-file-parts.txt
}

# concatenate part numbers with all sizes to be matched with prices later
permutation_creation() {
	# ensure file is empty before output is created
	> $tdir/permutations.txt	
	part_perms=()
	i=1
	l=0
	parts_array_length=`expr ${#parts_array[@]}`
	sa=${#size_array[@]}
	test_amt=`expr $parts_array_length \* $sa`
	while [ $i -lt $parts_array_length ]
	do
		n=0
		while [ $n -lt ${#size_array[@]} ]
		do
			f=`expr "${#part_perms[@]}" + 1`
			part="${parts_array[$i]}-"
			size="${size_array[$n]}"
			part_perms[$f]=${part}${size}
			n=`expr $n + 1`			
			l=`expr $l + 1`
			# Append to file of permuatations as to not overwrite its contents
			printf "${part_perms[$f]}\n" >> $tdir/permutations.txt
		done
		i=`expr $i + 1`
	done
	i=0
	final_part_array=()
	while IFS='' read -a my_array
	do
		final_part_array[$i]=$(tr -d '\040\011\012\015' <<< "${my_array[@]}")
		# print value to file for checking if errors exist
		i=`expr $i + 1`
	done < $tdir/permutations.txt
	printf %s "${final_part_array[*]}" > $tdir/final_part.txt
}

# select_prices function stores prices from the original data file into a new file for manipulation
select_prices() {
	calc=""
	if [[ $need_splodin = 0 ]]; then
		while read line; do
			calc=$(($calc + $line))
		done < $tdir/recalculation.txt
		calc=$(($calc + 1))
		new_range=2-$calc
	else
		new_range=$price_size_fields
	fi
		i=0
		temp_array=()
	while read; do
		temp_array[$i]=$(sed 's/,*$//' | cut -d ',' -f $new_range)		
		echo "${temp_array[@]}" > $tdir/price-file.txt
		i=`expr $i + 1`
	done < $reused_datafile	
}

split_price() {
	prices=()
	l=1
	parts_array_length=`expr ${#parts_array[@]}`
	# create array of prices to later be added into final txt doc with corresponding part permutation
	while [ $l -lt $parts_array_length ]
	do
		prices[$l]=$(sed -n "$l{p}" < $tdir/price-file.txt)
		l=`expr $l + 1`
	done
	> $tdir/prices.txt
	fin_price=()
	i=0
	z=1
	parts_array_length=`expr ${#parts_array[@]} - 1`
	# split each comma delimited line into newline on each comma to be stored into individual array elements for matching with part permutation
	while [ $i -lt $parts_array_length ]
	do
		line=$(sed -n "$z{p}" < $tdir/price-file.txt)
		n=0
		IFS=',' read -r -a array <<< $line

		while [ $n -lt ${#size_array[@]} ]
		do
			echo "${array[$n]}" >> $tdir/prices.txt
			n=`expr $n + 1`
		done
	i=`expr $i + 1`
	z=`expr $z + 1`
	done
	final_price_array=()
	i=0
	# storing each line of now individual prices into an array for easy matching with corresponding part permutation
	while IFS='' read -a my_array
	do
		final_price_array[$i]="${my_array[@]}"
		i=`expr $i + 1`
		# finished using $tdir/permutations.txt		
	done < $tdir/prices.txt
	printf %s "${final_price_array[*]}" > $tdir/final_price.txt
}

# print part number next to price
final_output() {
	> $tdir/output.txt
	length=`expr ${#final_part_array[@]}`
	i=0
	while [ $i -lt $length ]
	do
		printf "${final_part_array[$i]},${final_price_array[$i]}\n" >> $tdir/output.txt
		i=`expr $i + 1`
	done
	sed -e 's/\(.*\)/\U\1/' $tdir/output.txt > $data/final_output.csv
	echo "Data is stored in $data/final_output.csv"	
}

debug() {
	# when debug equals 1, all of the files in the temp directory will be cleared
	# when debug equals 2, default text editor will open the output of the script 

	if [ -z "$debug" ]; then
		exit
	fi
	if [[ "$debug" -eq 1 ]]; then
		rm $tdir/*
	fi
	if [[ "$debug" -eq 2 ]]; then
		xdg-open $data/final_output.csv
	fi
}


main() {
	### sploder
	trim_format
	explode_sizes
	final_splosion

	### spb
	retrim
	split_lines
	get_sizes
	get_parts
	permutation_creation
	select_prices
	split_price
	final_output
	debug
}
main