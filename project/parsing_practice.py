#practice for parsing

infile = open ("iqtree_full.txt", "r")
outfile = open ("practiceparsing.txt", "w")
sta = "                     Gap"
stop = "****  TOTAL"
start_parsing = False



for line in infile:
    if line.startswith(sta):
        start_parsing = True
        print (line)
        
    if line.startswith(stop):
        break
    
    if start_parsing:
        items = line.rsplit()
        dataline = (",".join(items))
        outfile.write(dataline + "\n")
    
    
infile.close()
outfile.close()
    