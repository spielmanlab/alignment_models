infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed_pattern.txt", "w")

       
for line in infile:

    ## We expect 7 items in a list
    ## The first item should BE ABLE to be int
    ## The third item should BE ABLE to be float
    
    items = line.rsplit()
    if len(items) == 7:
    
        try:
            first_item = int(items[0])
            #type(items[0]) == "int" :
            #print(first_item)
            dataline = (",".join(items))
            outfile.write(dataline + "\n")
        except:
            if items[0] == "No.":
                dataline = (",".join(items))
                outfile.write(dataline + "\n")
    
    
    
    
    
    
    
    
#         items = line.rsplit()
#         dataline = (",".join(items))
#         outfile.write(dataline + "\n")


infile.close()
outfile.close()