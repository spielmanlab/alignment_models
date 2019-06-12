infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed2.txt", "w")
iqline = infile.readline()
sta = " No. "
stop = "Akaike"
start_parsing = False


		
for line in infile:
	if line.startswith(sta):
		start_parsing = True
		if start_parsing:
			for line in infile:
				items = line.rsplit()
				dataline = (",".join(items))
				outfile.write(dataline + "\n")
		elif line.startswith(stop):
			start_parsing = False
			break
				
########################################				
#parse = false
#for each line in file
#check - start_parsing? if so, parse = T
#check - stop parsing? if so, parse = false
#if i should parse this line, parse items

#wrong
#for line in infile:
#	if line.startswith(sta):
#		start_parsing = True
#	elif line.startswith(stop):
#		start_parsing = False
#		if start_parsing == True:
#			for line in infile:
#				items = line.rsplit()
#				dataline = (",".join(items))
#				outfile.write(dataline + "\n")
#		elif start_parsing == False:
#			for line in infile:
#				delete = line.strip()
#				dataline2 = (line.replace(delete, ""))
#				outfile.write(dataline2)
			
###############################################	
			
			
#for a line in file
#if line startswith : start, then start_parsing is true
#if line startswith : stop, then start_parsing is false 

#print over every line you're looping over:
 
##############################################################

#for line in infile:
#	if line.startswith(sta):
#		print (line.startswith(stop))
#		start_parsing = False
#		print (start_parsing)
#		if line.startswith(sta):
#			print (line.startswith(stop))
#			start_parsing = True
#			if start_parsing:
#				continue
#				for line in infile:
#					items = line.rplit()
#					print (items)
#					dataline = (",".join(items))
#					print (dataline)
#					outfile.write(dataline + "\n")
#					print (dataline + "\n")
#	else:
#		break
				
infile.close()
outfile.close()
