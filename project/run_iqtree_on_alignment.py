import os

#### Create a list of all the alignment (".fasta") files we want to run through iqtree
all_files = os.listdir(".") ## list all files in current directory (".")
# fasta_files = [x for x in all_files if x.endswith(".fasta")] ## this is called "list comprehension" and is a fancy python way to do lists
fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        fasta_files.append(file)


# Run iqtree over all files, parse the model information, and save!
for file in fasta_files:
   print("Running model selection on", file) 
   
   ### Run through iqtree
   iqtree_success = os.system("iqtree -s " + file + " -m TESTONLY -st AA -quiet -redo")
   assert iqtree_success == 0, "ERROR: iqtree did not run properly"
   
   ### Parse the output "log" file
   logfile = file + ".log"
   csvfile = file.replace(".fasta", "_models.csv") # where to save parsing output
   ### ......forthcoming code......
   
   
   ## Remove the vomit
   os.system("rm " + file + ".*") 