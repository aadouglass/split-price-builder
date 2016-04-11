#!/bin/bash

# data_file is argument 1
data_file=$1
# size_line is argument 2, what line are the sizes located?
size_line=$2

# Clean the variable with sizes to clear white space
trim_sizes() {
temp_sizes1=$(sed -n "${size_line}p" "$data_file")
temp_sizes2=$(sed -e 's/^,*//g; s/,*$//g' <<< $temp_sizes1)
sizes=$(sed 's/ //g' <<< $temp_sizes2)
}

# Initiate row_array to store each row from argument 1 data_file using the while loop
row_array=()
# Splits each row of a document into an element of row_array
split_lines() {
	i=0
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
		# print value to file for checking
		printf %s "${row_array[*]}" > 'input-file-rows.txt'
		i=`expr $i + 1`
		# Use echo $i when modifying function to find errors by line
		# echo $i
		# finished using data_file		
	done < $data_file
}

# Initiate size_array to store sizes from the an element of row_array
size_array=()
# Split element with sizes into a new array by passing the row that sizes exist in the document
# Sizes will be used to create SKU permutations in later function
get_sizes() {
		IFS=',' read -a size_array <<< $sizes
		# print value to file for checking
		printf %s "${size_array[*]}" > 'input-file-sizes.txt'
}
# create parts_array to store all part numbers for creating part number permutations
parts_array=()
temp_part=()
# Extract all part numbers from given file to later create permutations of the numbers with sizes
get_parts() {
	f1() {
	temp_part=$(cut -d',' -f1 $data_file)
	# print value to file for checking
	printf %s "${temp_part[*]}" > 'input-file-parts.txt'
	}
	f1
	sed -i -e '$a\' 'input-file-parts.txt'
	i=0
	f2() {
	while IFS='\n' read -a another_array
	do
		parts_array[$i]="${another_array[@]}"
		printf %s "${parts_array[*]}" > 'output-file-parts.txt'
		i=`expr $i + 1`
	done < input-file-parts.txt
	}
	f2
}
# create array part_perms to store permutations of part numbers with sizes
part_perms=()
# create function that will concatenate part numbers with all sizes
permutation_creation() {
	# ensure file is empty before output is created
	> permutations.txt
	i=1
	l=0
	pa=`expr ${#parts_array[@]}`
	sa=${#size_array[@]}
	test_amt=`expr $pa \* $sa`
	while [ $i -lt $pa ]
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
			printf "${part_perms[$f]}\n" >> 'permutations.txt'
		done
		i=`expr $i + 1`
	done
}

# Call functions
call_all() {
trim_sizes
split_lines
get_sizes
get_parts
permutation_creation
}
call_all
# open file at end of script to see output
xdg-open permutations.txt