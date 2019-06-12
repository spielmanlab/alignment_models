infile = open ("iqtree_full.txt", "r")
outfile = open ("fullparsed_indicator.txt", "w")
sta = " No. "
stop = "Akaike"
start_parsing = False

#infile.seek(0)

       
for line in infile:
    #print(line)
    if line.startswith(sta):
        start_parsing = True
    if line.startswith(stop):
        break        
            
    if start_parsing:
        items = line.rsplit()
        dataline = (",".join(items))
        outfile.write(dataline + "\n")


infile.close()
outfile.close()