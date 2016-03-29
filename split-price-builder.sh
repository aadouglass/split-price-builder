#!/bin/bash

	                          
data_file=$1                                               # data_file is arg1
while IFS=$',' read -a my_array || [[ -n "$my_array" ]];   # Create an array with each field of current line
do
	echo ${my_array[@]}                                 	   # Write out all elements of the array
done < $data_file                                          # Done using $data_file