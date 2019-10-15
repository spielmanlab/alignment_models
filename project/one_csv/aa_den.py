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
    
    tree = dendropy.Tree.get(
    path= aa_output_tree_file,
    schema="newick")
    

        
        #aa_output_tree_file = aa_path_to_alignments + str(path)
        #print(aa_output_tree_file)
                
                
    