Price Builder ReadMe
Price Builder is a script that will extract part numbers with multiple sizes and create all permutations for the part and size and match corresponding prices from a given .csv file. If the file is not in .csv format, open the document and save as .csv file format found in the options after clicking the down arrow in file template.

This script requires bash which is found on just about every distribution of linux as the default shell
You will need to add a couple of directories for temp files and data
Run the spb-install.sh to create necessary directories for temporary files and data.

p#=Parameter number
bash script-name.sh p1 p2 p3 p4

There are four parameters to be passed to the script:
Parameter 1: The path to the .csv file containing parts and prices.
Parameter 2: The line number containing sizes for the products.
Parameter 3: The range of column fields that the prices span across. (ex. 'xxxxx,xxxxxxxx,xxxxxxxxxxx,xxx,xxxx,xxx,$12.45,$54.21,123.92' parameter = 1-3. Another ex. 'xxxxx,xxxxxxxx,xxxxxxxxxxx,xxx,xxxx,xxx,$12.45,$54.21,123.92,xxx,xxxxxx' parameter = 3-5).
Parameter 4: Debug options: 1 will clear the temp directory, 2 will open the output file, anything else will be ignored, including empty values.

$ ./split-price-builder.sh data/file.csv 1 2-4 2
 part1, price
 part2, price
 part3, price
 part4, price
 part5, price
 part6, price
 part7, price
 ............
 ............
 ............
$ 
Version 1.0

Andrew Douglass/Dooley Tackaberry Inc.

Homepage: www.dooleytackaberry.com
e-mail: adouglass@safetyfire.com