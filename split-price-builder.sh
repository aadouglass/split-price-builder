#!/bin/bash

# give me the path to the data
data_file=$1
# what line are the sizes located?
size_line=$2
# from end of line what is the range of fields of prices?
select_fields=$3
# if you want to clear temp files created in script, pass '1'
# if you want to see the output of the script, pass '2'
debug=$4
# a simple variable denoting temporary directory
tdir="tmp/"

cd; cd bash-scripts;

# Clean the variable with sizes to clear white space
trim_sizes() {
	temp_sizes1=$(sed -n "${size_line}p" "$data_file")
	temp_sizes2=$(sed -e 's/^,*//g; s/,*$//g' <<< $temp_sizes1)
	sizes=$(sed 's/ //g' <<< $temp_sizes2)
}


# Splits each row of a document into an element of row_array for easier manipulation
split_lines() {
	i=0
	row_array=()
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
		# print value to file for checking if errors exist
		printf %s "${row_array[*]}" > "$tdir"input-file-rows.txt
		i=`expr $i + 1`
		# finished using data_file		
	done < $data_file
}



# Sizes are extracted to create SKU permutations in later function
get_sizes() {
	size_array=()
	IFS=',' read -a size_array <<< $sizes
	# print value to file for checking if errors exist
	printf %s "${size_array[*]}" > "$tdir"input-file-sizes.txt
}


# Extract all part numbers from given file to later create permutations of the numbers with sizes
get_parts() {
	temp_part=()
	parts_array=()
	# 
	temp_part=$(cut -d',' -f1 $data_file)
	# print value to file for checking if errors exist and to manipulate data further
	printf %s "${temp_part[*]}" > "$tdir"input-file-parts.txt
	sed -i -e '$a\' "$tdir"input-file-parts.txt
	i=0
	while IFS='\n' read -a another_array
	do
		parts_array[$i]="${another_array[@]}"
		printf %s "${parts_array[*]}" > "$tdir"output-file-parts.txt
		i=`expr $i + 1`
	done < "$tdir"input-file-parts.txt
}


# concatenate part numbers with all sizes to be matched with prices later
permutation_creation() {
	# ensure file is empty before output is created
	> "$tdir"permutations.txt	
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
			printf "${part_perms[$f]}\n" >> "$tdir"permutations.txt
		done
		i=`expr $i + 1`
	done
	i=0
	final_part_array=()
	while IFS='' read -a my_array
	do
		final_part_array[$i]="${my_array[@]}"
		# print value to file for checking if errors exist
		i=`expr $i + 1`
	done < "$tdir"permutations.txt
	printf %s "${final_part_array[*]}" > "$tdir"final_part.txt
}



# select_prices function stores prices from the original data file into a new file for manipulation
select_prices() {
	i=0
	while read
		do
			# select_fields is the third argument, count starting at 1 from the end of line (last price) to first price (somewhere in the middle of the line)
			temp_array[$i]=$(sed 's/,*$//' | rev | cut -d ',' -f $select_fields | rev)		
			echo "${temp_array[$i]}" > "$tdir"price-file.txt
			i=`expr $i + 1`
	done < $data_file	
}


split_price() {
	prices=()
	l=1
	parts_array_length=`expr ${#parts_array[@]}`
	# create array of prices to later be added into final txt doc with corresponding part permutation
	while [ $l -lt $parts_array_length ]
	do
		prices[$l]=$(sed -n "$l{p}" < "$tdir"price-file.txt)
		l=`expr $l + 1`
	done
	> "$tdir"prices.txt
	fin_price=()
	i=0
	z=1
	parts_array_length=`expr ${#parts_array[@]}`
	# split each comma delimited line into newline on each comma to be stored into individual array elements for matching with part permutation
	while [ $i -lt $parts_array_length ]
	do
		line=$(sed -n "$z{p}" < "$tdir"price-file.txt)
		n=0
		IFS=',' read -r -a array <<< $line
		while [ $n -lt ${#size_array[@]} ]
		do
			echo "${array[$n]}" >> "$tdir"prices.txt
			n=`expr $n + 1`
		done
	i=`expr $i + 1`
	z=`expr $z + 1`
	done
	removing_newlines_from_end_of_doc=$(<"$tdir"prices.txt); printf '%s\n' "$removing_newlines_from_end_of_doc" > "$tdir"prices.txt
	final_price_array=()
	i=0
	# storing each line of now individual prices into an array for easy matching with corresponding part permutation
	while IFS='' read -a my_array
	do
		final_price_array[$i]="${my_array[@]}"
		i=`expr $i + 1`
		# finished using "$tdir"permutations.txt		
	done < "$tdir"prices.txt
	printf %s "${final_price_array[*]}" > "$tdir"final_price.txt
}


# print part number next to price
final_output() {
	> data/final_output.txt
	length=`expr ${#final_price_array[@]}`
	i=0
	while [ $i -lt $length ]
	do
		printf "${final_part_array[$i]},${final_price_array[$i]}\n" >> data/final_output.txt
		i=`expr $i + 1`
	done
	echo "Data is stored in data/final_output.txt"
}



# when debug equals 1, all of the files in the temp directory will be cleared
# when debug equals 2, default text editor will open the output of the script 
debug() {
	if [ -z "$debug" ]; then
		exit
	fi
	if [[ "$debug" -eq 1 ]]
		then
		rm "$tdir"*
	fi
	if [[ "$debug" -eq 2 ]]
		then
		xdg-open final_output.txt
	fi
}



# Call functions
main() {
	trim_sizes
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