#!/bin/bash


data_file=$1
sizes=$2
row_array=()
i=0
line_splitter() {
	while IFS='' read -a my_array
	do
		row_array[$i]="${my_array[@]}"
		i=`expr $i + 1`
	done < $data_file
	
}

size_array=()
c=0
get_sizes() {

	IFS=',' read -a size_array <<< $row_array[$2]
}

line_splitter
get_sizes
