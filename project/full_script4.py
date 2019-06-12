infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed2.txt", "w")
iqline = infile.readline()
sta = " No. "
stop = " Akaike"
start_parsing = False



for line in infile:
	if line.startswith(sta):
		start_parsing = True
		if start_parsing:
			for line in infile:
					items = line.rsplit()
					dataline = (",".join(items))
					outfile.write(dataline + "\n")
					print (dataline)
		else:
			break
		

			 