# price-builder.sh ReadMe

Price Builder is a script that will extract part numbers with multiple sizes and create all permutations for the part and variation of sizes and match corresponding prices from a given .csv file. If the file is not in .csv format, open the document and save as .csv file format found in the options after clicking the down arrow in file template.

This script requires bash which is found on just about every distribution of linux as the default shell
You will need to add a couple of directories for temp (tmp) files and data
Run the spb-install.sh to create necessary directories for temporary files and data.

bash price-builder.sh parameter1 parameter2 parameter3 parameter4 parameter5 parameter6

There are six parameters to be passed to the script:
* Parameter 1: The path to the .csv file containing parts and prices.
* Parameter 2: This will be '0' if you need to expand a column holding a range of sizes into more columns of individual sizes, otherwise pass '1'.
* Parameter 3: The range of columns/fields that the prices span across.

| field 1 | field 2 | field 3 | field 4 | S-XL  | 2XL-4XL | 5XL-7XL |
|---------|---------|---------|---------|-------|---------|---------|
| part1   | field 2 | field 3 | field 4 | 12.45 | 18.21   | 23.92   |
| part2   | field 2 | field 3 | field 4 | 21.55 | 24.95   | 29.95   | 

parameter = 5-7).
* Parameter 4: Field/Column number containing parts/products.
* Parameter 5: The line number containing sizes for the products.
* Parameter 6: Debug options: 1 will clear the temp directory, 2 will open the output file, anything else will be ignored, including empty values.

Example:
This will use the data within file.csv located in the data directory, explode any ranges of data found in columns 5-7, and open the output in your default text editor called by the last parameter '2', if it was '1', tmp/files would be deleted.
```
$ bash ./split-price-builder.sh data/file.csv 0 5-7 1 1 2
 part1-S, price
 part1-M, price
 part1-L, price
 part1-XL, price
 part1-2XL, price
 part1-3XL, price
 part1-4XL, price
 part1-5XL, price
 part1-6XL, price
 part1-7XL, price
 part2-S, price
 ............
 ............
 ............
 lastpart-7XL, price
$
```
Version 1.0

Andrew Douglass/Dooley Tackaberry Inc.

Homepage: www.dooleytackaberry.com
e-mail: adouglass@safetyfire.com