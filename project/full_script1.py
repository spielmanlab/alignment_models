#python script for parsed "iqtree_full.txt" 

import re

iqf = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed.txt", "w")

iqline = iqf.read()


for line in iqline: 
	items = iqline.strip()
	dataline =  (",".join(items))
	outfile.write(dataline + "\n")
	iqline = iqf.readline()
	
iqf.close()
outfile.close()

