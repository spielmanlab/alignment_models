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
counter = 0
file_a1ending = "alnversion_1.fasta"

nt_paths = []
nt_aln_1 = []


#aa files for fast tree
for file in aa_all:
    name = str(file)
    x = name.endswith(file_ending)
    if x:
        aa_paths.append(file + "/")
        
#print("length:" + len(aa_paths))

    for path in aa_paths:   
        aa_files =  os.listdir(aa_path_to_alignments + path)
        for a1 in aa_files:
            aa_file_ending = a1.endswith(file_a1ending)
            if aa_file_ending:
                aa_aln_1.append(a1)
                
                

        aa_output_tree_file = aa_path_to_alignments + str(path) + str(aa_aln_1) + ".tree"
        #print(aa_output_tree_file)   
    
        os.system("FastTree <> - nosupport - quiet" + aa_path_to_alignments + str(path) + str(aa_aln_1) + ">" + aa_output_tree_file)

aa_tree = dendropy.Tree.get(
    path=output_tree_file,
    schema="newick")
    
aa_pdc = aa_tree.phylogenetic_distance_matrix()
print(aa_pdc.mean_pairwise_distance()) #### average pairwise distance between sequences


###########################################################################################
###########################################################################################


#nt files for fast tree

for file in nt_all:
    name2 = str(file)
    y = name2.endswith(file_ending)
    if y:
        nt_paths.append(file + "/")
    
    for path2 in nt_paths:
        nt_files = os.listdir(nt_path_to_alignments + path2)
        for n1 in nt_files:
            nt_file_ending = n1.endswith(file_a1_ending)
            if nt_file_ending:
                nt_aln_1.append(n1)

    nt_output_tree_file = nt_path_to_alignments + str(path2) + str(nt_aln_1) + ".tree"
    print(nt_output_tree_file)



    os.system("FastTree <> - nosupport - quiet" + nt_path_to_alignments + str(path2) + str(nt_aln_1) + ">" + nt_output_tree_file)
    
nt_tree = dendropy.Tree.get(
    path=output_tree_file,
    schema="newick")
    
nt_pdc = aa_tree.phylogenetic_distance_matrix()
print(nt_pdc.mean_pairwise_distance()) #### average pairwise distance between sequences
    







