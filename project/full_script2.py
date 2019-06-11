infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed2.txt", "w")
#content = infile.read()
#iqline = infile.readline()
#iqlines = infile.readlines()
#memory don't read 3 times
parse1 = False 
parse2 = True 




i = 0
for line in infile:
	i += 1
	item = line.startswith(" " + str(i))
	print (item)
	if i >= 9:
		break
		
		
for line in infile:
	print (line)
	if line.startswith(" No. Model")
	

#if it is, then keep using that, then when it is not, then stop:
#parse - keep it true until it isn't, then you can break when it's false (after akaike)
#loop over the file, then if, and then another for statment, like three lines of code?
		
		
	

for line in iqlines:
	print (line)
	x += 1
	y = " " + str(x)
	item = line.startswith(y)
	if item:
		print (line)

infile.close()
outfile.close()