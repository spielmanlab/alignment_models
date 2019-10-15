import dendropy ### Full documentation: https://dendropy.org/
import numpy as np
import os
import sys

nt_path_to_alignments = "../selectome_nt_output/"


nt_all = os.listdir(nt_path_to_alignments)

file_ending = ".fas_alnversions"

file_a1ending = "alnversion_1.fasta"
nt_paths = []
nt_aln_1 = []
counter = 0
counter2 = 0

for file in nt_all:
    name = str(file)
    x = name.endswith(file_ending)
    if x:
        nt_paths.append(file + "/")
        
#print(aa_paths)
    
for path in nt_paths:    
    nt_files = os.listdir(nt_path_to_alignments + path)
    for n1 in nt_files:
        nt_file_ending = n1.endswith(file_a1ending)
        if nt_file_ending:
            nt_aln_1.append(n1)

    nt_output_tree_file = nt_path_to_alignments + str(nt_paths[counter]) + str(nt_aln_1[counter]) + ".tree"
    counter += 1
    print(nt_output_tree_file)
    
    #print("FastTree <> -nosupport -quiet" + aa_path_to_alignments + aa_paths[counter2] + aa_aln_1[counter2] + " > " + aa_output_tree_file)
    #os.system("FastTree <> -nosupport -quiet " + aa_path_to_alignments + aa_paths[counter2] + aa_aln_1[counter2] + " > " + aa_output_tree_file)
  