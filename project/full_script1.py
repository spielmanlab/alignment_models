#python script for parsed "iqtree_full.txt" 

import re

iqf = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed.txt", "w")

iqline = iqf.readline()
iqlines = iqf.readlines()
#ALWAYS USE READLINE(S) 

for line in iqline:
	if line.startswith("ModelFinder will test 168 protein models (sample size: 815) ..."):
		items = line.split()
		dataline = ",".join(items)
		outfile.write (items + "\n")
		
		
	
		
		
		
		
		
		
		 #questionable-
		#begin parsing
		
		
	#index at lines
for x in range(1, 10, 1):
	x = "  " + str(x)
	for line in iqlines:
		item = line.startswith(x)
		if item:
			dataline = (",".join(line))
			outfile.write(dataline + "\n")
			iqlines = iqf.readlines()



### for x in range(1, 10, 1):
#...     x = "  " + str(x)
#...     for line in iqline:
#...             item = line.startswith(x)
#...             if item:
#...                     dataline = line + "\n"
#...                     print (dataline)
#... 


# fake?
>>> for x in range (1, 169, 1):
...     x = " " + str(x)
...     for line in iqlines:
...             item = line.startswith(x)
...             if item:
...                     dataline = (",".join(line))
...                     outfile.write(dataline + "/n")
...                     iqlines = infile.readlines()
... 

#fake????
for x in range(1, 169, 1):
...     x = " " + str(x)
...     for line in iqlines: 
...             item = line.startswith(x)
...             if item:
...                     data = line.split()
...                     dataline = (",".join(line))
...                     outfile.write(dataline + "\n")
...                     iqlines = infile.readlines()

#what i'm trying to do is make two variables with two different sets of white space, and print them out at the same time

for x in range(1, 10, 1):
...     x += 1
...     for line in iqline:
...             item = line.startswith(y)
...             if item:
...                     print (line)


#am i doing anything right HAH





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
	
	
	#ohhhh maybe do in range with startswith
	
	
	
iqf.close()
outfile.close()

