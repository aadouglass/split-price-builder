#!/bin/bash

# data_file is argument 1
data_file=$1
# size_line is argument 2, what line are the sizes located?
size_line=$2
# select_fields is argument 3, from end of line what is the range of fields of prices?
select_fields=$3
# Clean the variable with sizes to clear white space
trim_sizes() {
	temp_sizes1=$(sed -n "${size_line}p" "$data_file")
	temp_sizes2=$(sed -e 's/^,*//g; s/,*$//g' <<< $temp_sizes1)
	sizes=$(sed 's/ //g' <<< $temp_sizes2)
}


# Initiate row_array to store each row from argument 1 data_file using the while loop
# Splits each row of a document into an element of row_array
split_lines() {
	i=0
	row_array=()
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
		# print value to file for checking
		printf %s "${row_array[*]}" > 'input-file-rows.txt'
		i=`expr $i + 1`
		# finished using data_file		
	done < $data_file
}


# Initiate size_array to store sizes from the an element of row_array
# Split element with sizes into a new array by passing the row that sizes exist in the document
# Sizes will be used to create SKU permutations in later function
get_sizes() {
	size_array=()
	IFS=',' read -a size_array <<< $sizes
	# print value to file for checking
	printf %s "${size_array[*]}" > 'input-file-sizes.txt'
}


# create parts_array to store all part numbers for creating part number permutations
# Extract all part numbers from given file to later create permutations of the numbers with sizes
get_parts() {
	temp_part=()
	parts_array=()
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
# create function that will concatenate part numbers with all sizes
permutation_creation() {
	permutations() {
		# ensure file is empty before output is created
		> permutations.txt	
		part_perms=()
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
	permutations
	create_final_part_array() {
		i=0
		final_part_array=()
		while IFS='' read -a my_array
		do
			final_part_array[$i]="${my_array[@]}"
			# print value to file for checking
			i=`expr $i + 1`
			# finished using permutations.txt		
		done < permutations.txt
		printf %s "${final_part_array[*]}" > 'final_part.txt'
	}
	create_final_part_array
}


# select_fields is the third argument, count starting at 1 from the end of line end on last price count
select_prices() {
	# select_prices function stores prices from the original data file into a new file for manipulation
		i=0
		while read
			do
			temp_array[$i]=$(sed 's/,*$//' | rev | cut -d ',' -f $select_fields | rev)		
			echo "${temp_array[$i]}" > 'price-file.txt'
			i=`expr $i + 1`
		done < $data_file	
}


split_price() {
	# the first function splits the lines of prices into an array
	first() {
		prices=()
		i=1
		pa=`expr ${#parts_array[@]}`
		while [ $i -lt $pa ]
		do
			line=$(sed -n "$i{p}" < price-file.txt)
			prices[$i]=$line
			i=`expr $i + 1`
		done
		printf '%s\n' "${prices[@]}" > prices.txt
	}
	first
	# the second function will split each line of prices into individual elements of a new array
	second() {
		> prices.txt
		fin_price=()
		i=0
		z=1
		pa=`expr ${#parts_array[@]}`
		while [ $i -lt $pa ]
		do
			line=$(sed -n "$z{p}" < price-file.txt)
			n=0
			IFS=',' read -r -a array <<< $line
			while [ $n -lt ${#size_array[@]} ]
			do
				echo "${array[$n]}" >> prices.txt
				n=`expr $n + 1`
			done
		i=`expr $i + 1`
		z=`expr $z + 1`
		done
		removing_newlines=$(<prices.txt); printf '%s\n' "$removing_newlines" > prices.txt
	}
	second
	create_final_price_array() {
		final_price_array=()
		i=0
		while IFS='' read -a my_array
		do
			final_price_array[$i]="${my_array[@]}"
			i=`expr $i + 1`
			# finished using permutations.txt		
		done < prices.txt
		printf %s "${final_price_array[*]}" > 'final_price.txt'
	}
	create_final_price_array
}
# print part number next to price
final_output() {
	> final_output.txt
	length=`expr ${#final_price_array[@]}`
	i=0
	while [ $i -lt $length ]
	do
		printf '%s %s\n' "${final_part_array[$i]}" "${final_price_array[$i]}" >> final_output.txt
		i=`expr $i + 1`
	done
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
}
main
# open file at end of script to view output
xdg-open final_output.txt




