import os
import sys


fasta_dir   = sys.argv[1]      # directory with all fasta files
name_prefix = sys.argv[2]      # expecting naming
start_fasta = int(sys.argv[3]) # first index
stop_fasta  = int(sys.argv[4]) # second index
datatype    = sys.argv[5].upper()      # AA or NT
threads     = sys.argv[6]      # threadzzz

if datatype == "NT":
    datatype = "DNA"

for i in range(start_fasta, stop_fasta + 1):
    
    name      = fasta_dir + name_prefix + i
    fastafile = name + ".fasta"
    logfile   = name + ".log"
    csvfile   = name + "_models.csv"

    print("Running model selection on", fastafile) 
   
    ### Run through iqtree
    cmd = "iqtree -s " + fastafile + " -m TESTONLY -st " + datatype + " -redo -quiet -nt " + str(threads)
    iqtree_success = os.system(cmd)
    assert iqtree_success == 0, "\nERROR: iqtree did not run properly"
   
    ### Create file handles for named files
    infile = open (logfile, "r")
    outfile = open (csvfile, "w")
  
    ### Code to parse (indicator method)
    for line in infile:
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
    ### CLOSE !!!!!
    infile.close()
    outfile.close()

    os.system("rm " + fastafile + ".*") 

