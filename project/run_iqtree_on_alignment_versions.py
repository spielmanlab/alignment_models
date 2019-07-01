import os
import sys

#### Create a list of all the alignment (".fasta") files we want to run through iqtree

fasta_dir = sys.argv[1]   #"../13PK-A_alnversions/"
datatype  = sys.argv[2]   ### AA or DNA
threads   = sys.argv[3]
all_files = os.listdir(fasta_dir)
## list all files in current directory (".")
# fasta_files = [x for x in all_files if x.endswith(".fasta")] ## this is called "list comprehension" and is a fancy python way to do lists
fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        fasta_files.append(file)
#print(fasta_files)


# Run iqtree over all files, parse the model information, and save!

for file in fasta_files:

    logfile = fasta_dir + file + ".log"
    csvfile = fasta_dir + file.replace(".fasta", "_models.csv") # where to save parsing output
    ## Use the os module to ask if the file has already been made. If so, don't make it again but move on
    if os.path.exists(csvfile):
       continue 
    
    print("              Running model selection on", file) 
   
   ### Run through iqtree
   
    cmd = "iqtree -s " + fasta_dir + file + " -m TESTONLY -st " + datatype + " -redo -quiet -nt " + threads
    iqtree_success = os.system(cmd)
    assert iqtree_success == 0, "ERROR: iqtree did not run properly"
   
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
    
    ######## Molly: See below this comment for lines that were buggy in your last version, and compare with git history of the file to see the differences.
    ## Remove the extra files FOR THIS FILE!!
    os.system("rm " + fasta_dir + file + ".*") 
    
    ### CLOSE !!!!!
    infile.close()
    outfile.close()
