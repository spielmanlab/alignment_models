#new fullscript for clarity
import re 

infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed2.txt", "w")

iqline = infile.readline()
start_parsing = False
sta = " No."
stop = " Akaike"


x = """for line in infile:
	if line.startswith(sta):
		start_parsing = True
	else:
		continue
	if start_parsing:
		if line.startswith(stop):
			break
		else:
			while iqline:
				items = iqline.split()
				dataline = (",".join(items))
				outfile.write(dataline + "\n")
				print (dataline)
		"""
				
		## parse
		#print every line that you're looping over and figure out where to put the parsin
		


##########################		

x = """for line in infile:
	if line.startswith(sta):
		start_parsing = True
	else:
		continue 
		if start_parsing:
			line.startswith(stop)
			break 
		else:
			items = iqline.split()
			dataline = (",".join(items))
			outfile.write(dataline + "\n")
			print (dataline) """


for line in infile:
	if line.startswith(sta):
		parse = True
		if parse:
			items = iqline.split()
			dataline = (",".join(items))
			outfile.write(dataline + "\n")
			print (dataline)
			
	
	
	
#for line in infile:
	if line.startswith(stop):
		parse = False


				
			
			
			
xz = """"	items = iqline.rsplit()
		dataline = (",".join(items))
		outfile.write(dataline + "\n")
		if line.startswith(stop):
			parse = False
			break
		"""
				
					

					
				
				
			
				
				

					
				
				
infile.close()
outfile.close()
		
	
				

		
	

			



#if it is, then keep using that, then when it is not, then stop:
#parse - keep it true until it isn't, then you can break when it's false (after akaike)
#loop over the file, then if, and then another for statment, like three lines of code?
		