import os

#### Create a list of all the alignment (".fasta") files we want to run through iqtree

fasta_dir = "../13PK-A_alnversions/"
all_files = os.listdir(fasta_dir)
## list all files in current directory (".")
# fasta_files = [x for x in all_files if x.endswith(".fasta")] ## this is called "list comprehension" and is a fancy python way to do lists
fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        fasta_files.append(file)
print(fasta_files)


# Run iqtree over all files, parse the model information, and save!

for file in fasta_files:
    print("Running model selection on", file) 
   
   ### Run through iqtree
   
    cmd = "iqtree -s " + fasta_dir + file + " -m TESTONLY -st AA -redo -nt 3"
    iqtree_success = os.system(cmd)
    assert iqtree_success == 0, "ERROR: iqtree did not run properly"
   
   ### Parse the output "log" file
    logfile = fasta_dir + file + ".log"
    csvfile = fasta_dir + file.replace(".fasta", "_models.csv") # where to save parsing output
    
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
    
   ## Remove the vomit
os.system("rm " + fasta_dir + file + ".*") 