#python script for parsed "iqtree_full.txt" 

import re

iqf = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed.txt", "w")

iqline = iqf.read()


while 


for line in iqline:
	items = line.split()
	if line == "ModelFiner"

#line needs to be split, so i can index it
#if line starts with modelfinder, then begin parsing
#if line starts with akaike, then end parsing
#need to do a while statement, to make each line a list, then a for statement 
# with an if statement to find starting

#make a function from sub_script1.py while statement(?)



for line in iqline: 
	items = iqline.strip()
	dataline =  (",".join(items))
	outfile.write(dataline + "\n")
	iqline = iqf.readline()
	
iqf.close()
outfile.close()

