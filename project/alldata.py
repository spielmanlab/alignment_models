### ALL DATASETS CSV

import Bio
import os

fasta_dir = "../alldatasets"
### hypothetical directory where we put everything

all_files = os.listdir(fasta_dir)

all_fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        all_fasta_files.append(file)
print all_fasta_files

name =
number_sequences =
min_sites =
max_sites = 
mean_sites = 
sd_sites = 

