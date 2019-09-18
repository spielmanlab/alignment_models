### Script to parse

### 15 lines

# Import libraries needed
from Bio import SeqIO
import os
import statistics

#Don't need tp put data into multiple lists

fasta_dir = "../one_csv/data/"
all_files = os.listdir(fasta_dir)
print(all_files)

all_fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        all_fasta_files.append(file)
print (all_fasta_files)



csvfile = fasta_dir + "one_csv"
outfile = (open, csvfile, "w")

names = []
numberseq = []
seqs = []

for file in all_fasta_files:

    fasta_records = list(SeqIO.parse(fasta_dir + file, "fasta"))

    z = file.rstrip(".fasta")
    names.append(z)
    x = len(fasta_records)
    numberseq.append(x)
    
    for rec in fasta_records:
        y = len(rec)
        seqs.append(y)
    


# Dictionary to put everything

parsingdict = {"names": names, "number_of_seq":numberseq,}

print(parsingdict.get("names"))
print(parsingdict.get("number_of_seq"))

###Parsing Code: 


   
    
singular_rec = ([mins[i::len(all_fasta_files)] for i in range(len(all_fasta_files))])
print(min(singular_rec))
stri = comma.join(map(str,singular_rec))

stri2 = stri.replace("[", "")
print(stri2)























