### parsing practice pattern

infile = open ("iqtree_full.txt", "r")
outfile = open ("practiceparsingpat.txt", "w")

for line in infile:

    items = line.rsplit()
    if len(items) == 5
    
    try:
        first_item = int(items[0])
        #type(items[0]) == "int" :
        #print(first_item)
         dataline = (",".join(items))
         outfile.write(dataline + "\n")
    
    except:
        if items[0] == "Gap/Ambiguity"
         dataline = (",".join(items))
         outfile.write(dataline + "\n")