#python script for parsed "iqtree_full.txt" 

import re

iqf = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed.txt", "w")

iqline = iqf.readline()
#ALWAYS USE READLINE(S) 

for line in iqline:
	if line.startswith("ModelFinder will test 168 protein models (sample size: 815) ..."):
		items = line.split()
		dataline = ",".join(items)
		outfile.write (items + "\n")
		
		
	
		
		
		
		
		
		
		 #questionable-
		#begin parsing
		
		
	#index at lines
 for x in range(1, 257, 1):
...     x = " " + str(x)
...     for line in iqlines:
...             item = line.startswith(x)
...             if item:
...                     dataline = (",".join(line))
...                     outfile.write(dataline + "\n")
...                     iqlines = infile.readlines()
... 

#while line.startswith(x):
	


#was going to split string into list, so i can index it, but now just going to use 
#startswith?


# if s2.startswith("Akaike Information Criterion")



#if the length is not 7 (list)

#just need to focus on where to start and when to stop parsing


#if line starts with modelfinder, then begin parsing
#if line starts with akaike, then end parsing
#need to do a while statement, to make each line a list, then a for statement 
# with an if statement to find starting

#make a function from sub_script1.py while statement(?)


#startwith


#for line in iqline: 
	
	
	
	
	
iqf.close()
outfile.close()

