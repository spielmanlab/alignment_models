import dendropy ### Full documentation: https://dendropy.org/
import numpy as np
import os
import sys


####### notes for writing this into a function
"""
arguments the function needs:
- path to alignment
- path to output file
"""
# def make_trees():
#     
# 
# 
#     return 0

nt_path_to_alignments = "../selectome_nt_output/"
aa_path_to_alignments = "../selectome_aa_output/"

path_to_aa_output_trees = aa_path_to_alignments + "alnversion1_trees/"
os.system("mkdir -p " + path_to_aa_output_trees)
path_to_nt_output_trees = nt_path_to_alignments + "alnvers1_trees/"
os.system("mkdir -p " + path_to_nt_output_trees)

aa_all = os.listdir(aa_path_to_alignments)
nt_all = os.listdir(nt_path_to_alignments)

file_ending = ".fas_alnversions"
file_a1ending = "alnversion_1.fasta"

#aa files for fast tree
for file in aa_all:
    name = str(file)
    x = name.endswith(file_ending)
    #### If variable `file` is a DIRECTORY, head into here:
    if x: 
        aa_files = os.listdir(aa_path_to_alignments + file)
       #print(aa_files)
        for a1 in aa_files:
            aa_file_ending = a1.endswith(file_a1ending)
            if aa_file_ending:
                aa_output_tree_file = path_to_aa_output_trees + a1 + ".tree"
                if os.path.exists(aa_output_tree_file):
                    if os.path.getsize(aa_output_tree_file) > 0:
                        continue
                print(aa_output_tree_file)
                cmd = "FastTree -nosupport -quiet " + aa_path_to_alignments + name + "/" + str(a1) + " > " + aa_output_tree_file
                # FAST TREE MP
                ### run the tree
                exit_code = os.system(cmd)
                assert(exit_code == 0), "bad fasttree"
                assert(os.path.getsize(aa_output_tree_file) > 0), "tree file size is 0"
                try:   
                    aa_tree = dendropy.Tree.get(
                        path=aa_output_tree_file,
                        schema="newick")  
                except:
                    #pass
                    continue


#nt files for fast tree

for file in nt_all:
    name = str(file)
    x = name.endswith(file_ending)
    #### If variable `file` is a DIRECTORY, head into here:
    if x: 
        nt_files = os.listdir(nt_path_to_alignments + file)
       #print(aa_files)
        for n1 in nt_files:
            nt_file_ending = n1.endswith(file_a1ending)
            if nt_file_ending:
                nt_output_tree_file = path_to_nt_output_trees + n1 + ".tree"
                if os.path.exists(nt_output_tree_file):
                    continue
                print(nt_output_tree_file)
                cmd = "FastTree -nt -gtr -nosupport -quiet " + nt_path_to_alignments + name + "/" + str(n1) + " > " + nt_output_tree_file
                ### run the tree
                exit_code = os.system(cmd)
                assert(exit_code == 0), "bad fasttree"
                try:   
                    nt_tree = dendropy.Tree.get(
                        path=nt_output_tree_file,
                        schema="newick")  
                except:
                    #pass
                    continue

    
    
    
    
    