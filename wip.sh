#!/bin/bash

# data_file is argument 1, sizes is argument 2
data_file=$1
size_line=$2
temp_sizes=$(sed -n "${size_line}p" "$data_file")
sizes=$(sed -e 's/^,*//g; s/,*$//g' <<< $temp_sizes)
# Initiate row_array to store each row from argument 1 data_file using the while loop
row_array=()
# Splits each row of a document into an element of row_array
split_lines() {
	i=0
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
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
		printf %s "${size_array[@]}" > 'input-file-sizes'
}

parts_array=()
get_parts() {
	parts_array=$(cut -d',' -f1 $data_file)
	printf %s "${parts_array[*]}" > 'input-file-parts.txt'
}





split_lines
#get_sizes
get_parts
printf $sizes > 'input-file-sizes'



xdg-open input-file-parts.txt
xdg-open input-file-rows.txt
xdg-open input-file-sizes.txt