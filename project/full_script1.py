#python script for parsed "iqtree_full.txt" 

import re

iqf = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed.txt", "w")

iqline = iqf.read()


while 


for s1 in iqlinez:
	if s1.startswith("ModelFinder"): #questionable-
		#begin parsing
		
		
	#index at lines
	s

#was going to split string into list, so i can index it, but now just going to use 
#startswith?


if s1.startswith("Akaike Information Criterion"")



#if the length is not 7 (list), 


#if line starts with modelfinder, then begin parsing
#if line starts with akaike, then end parsing
#need to do a while statement, to make each line a list, then a for statement 
# with an if statement to find starting

#make a function from sub_script1.py while statement(?)


#startwith


for line in iqline: 
	items = iqline.strip()
	dataline =  (",".join(items))
	outfile.write(dataline + "\n")
	iqline = iqf.readline()
	
iqf.close()
outfile.close()

