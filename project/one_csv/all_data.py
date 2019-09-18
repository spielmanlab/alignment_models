### ALL DATASETS CSV


#Importing all libraries needed!

from Bio import SeqIO
import os
import statistics
import csv
from itertools import islice


fasta_dir = "../alldatasets_csv/data/"
### hypothetical directory where we put everything
all_files = os.listdir(fasta_dir)
all_fasta_files = []
#print (all_files)


######################################################################
for file in all_files:
    if file.endswith(".fasta"):
        all_fasta_files.append(file)
#print (all_fasta_files)

names = []
### Prints all the names without extension, puts it into list
for items in all_fasta_files:
    x = items.rstrip(".fasta")
    names.append(x)
print("Names of all the files:", names)
###########################################################################


### Reading and Writing files to parse!

dummylist = []
seq_list= []
number_of_sequences = []
counter = []

csvfile = "summary_of_fastas.csv" #fasta_dir + file.replace(".fasta", "_adata.csv")


for file in all_fasta_files:
    print("Running analysis on:",file)
    records = list(SeqIO.parse(fasta_dir + file, "fasta"))
    print("List of records:", records)
    
    
    ### opening and creating files to work with
    f_file = fasta_dir + file 
    csvfile = fasta_dir + file.replace(".fasta", "_adata.csv")

    infile = open (f_file, "r")
    outfile = open (csvfile, "w")
    

    
### prints number of sequences
    print ("Numbber of sequences in one file:", len(records))
    z = len(records)
    number_of_sequences.append(z)
    print("Number of sequences in all files:", number_of_sequences)
    
    
###getting different lists for different sequences
### Want to create separate lists for each file

    for rec in records:
        x = len(rec)
        print("length of a sequence:", x)
        dummylist.append(x)
        print("dumm", dummylist)
    
    for i in range(number_of_sequences[0]):   
        print("blah", dummylist.append([]))
        for j in range(number_of_sequences[0]):
           print(dummylist[i])
    print (dummylist)
    
   
    
          
    
        

#print(min(slist))
#print(max(slist))
#print(statistics.stdev(slist))
#print(statistics.mean(slist))       
    
    
        
    #### Code to parse:
    for line in infile:
        items = []
        if len(items) == 6:
            
            first_item = str(names[0])
            second_item = number_of_sequences[0]
            third_item = min_sites[0]
            fourth_item = max_sites[0]
            fifth_item = meansite[0]
            sixth_item = stdevsite[0]
            
            ##put in list - save [0[ as str]
            items.append(first_item+second_item+third_item+fourth_item+fifth_item+sixth_item)
            items.split(line)
            dataline = (",".join(items))
            #outfile.write(dataline + "\n")
            
            




# for file in all_fasta_files:
# 
#     f_file = fasta_dir + file 
#     csvfile = fasta_dir + file.replace(".fasta", "_adata.csv")
# 
#     #print (f_file)
#     #print (csvfile)
# 
#     infile = open (f_file, "r")
#     outfile = open (csvfile, "w")
# 
#     ### Code to count number of sequences
#     number_sequences = [] 
#     seq = []
#     for line in infile: 
#         print (line)
#         if line.startswith(">seq"):
#             seq.append(line)
#             print (seq)
#             z = seq.count(">seq")
#             number_sequences.append(z)
#             print (number_sequences)




### Removing extra files
    #os.system("rm" + fasta_dir + file + ".*")



# Close files!!!      
infile.close()
outfile.close()               
                
                
                
                
                
                
                
                
                
