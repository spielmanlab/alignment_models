import dendropy ### Full documentation: https://dendropy.org/
import numpy as np
import os
import sys

nt_path_to_alignments = "../selectome_nt_output/"
aa_path_to_alignments = "../selectome_aa_output/"

aa_all = os.listdir(aa_path_to_alignments)
nt_all = os.listdir(nt_path_to_alignments)

file_ending = ".fas_alnversions"
aa_paths = []
aa_aln_1 = []
file_a1ending = "alnversion_1.fasta"
nt_paths = []
nt_aln_1 = []
counter = 0
counter2 = 0
counter3 = 0
counter4 = 0

# cmd = os.system("FastTree -nt -gtr -nosupport -quiet " + path_to_alignments + path2 + file + " > " + output_tree_file)

#aa files for fast tree
for file in aa_all:
    name = str(file)
    x = name.endswith(file_ending)
    if x:
        aa_paths.append(file + "/")
        
#print(aa_paths)
    
for path in aa_paths:    
    aa_files = os.listdir(aa_path_to_alignments + path)
    for a1 in aa_files:
        aa_file_ending = a1.endswith(file_a1ending)
        if aa_file_ending:
            aa_aln_1.append(a1)

    aa_output_tree_file = aa_path_to_alignments + str(aa_paths[counter]) + str(aa_aln_1[counter]) + ".tree"
    counter += 1
    #print(aa_output_tree_file)
    
    #print("FastTree <> -nosupport -quiet" + aa_path_to_alignments + aa_paths[counter2] + aa_aln_1[counter2] + " > " + aa_output_tree_file)
    #os.system("FastTree <> -nosupport -quiet " + aa_path_to_alignments + aa_paths[counter2] + aa_aln_1[counter2] + " > " + aa_output_tree_file)
    counter2 += 1
    
#nt files for fast tree

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

    nt_output_tree_file = nt_path_to_alignments + str(nt_paths[counter3]) + str(nt_aln_1[counter3]) + ".tree"
    counter3 += 1
    #print(nt_output_tree_file)
    
    
    #print("FastTree -nt -gtr -nosupport -quiet" + nt_path_to_alignments + nt_paths[counter4] + nt_aln_1[counter4] + " > " + nt_output_tree_file)
    os.system("FastTree -nt -gtr -nosupport -quiet " + nt_path_to_alignments + nt_paths[counter4] + nt_aln_1[counter4] + " > " + nt_output_tree_file)
    counter4 += 1
    

    
    
    
    
    