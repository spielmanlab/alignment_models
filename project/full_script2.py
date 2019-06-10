infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed2.txt", "w")
content = infile.read()
iqline = infile.readline()
iqlines = infile.readlines()

i = 0
for line in infile:
	i += 1
	item = line.startswith(" " + str(i))
	print (item)
	if i >= 9:
		break
		
		
	

for line in iqlines:
	print (line)
	x += 1
	y = " " + str(x)
	item = line.startswith(y)
	if item:
		print (line)

infile.close()
outfile.close()