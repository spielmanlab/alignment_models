import dendropy ### Full documentation: https://dendropy.org/
import numpy as np
import os
import sys
import statistics
from Bio import SeqIO

### VARS FOR DENDROPY   
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
#########################################################################################
### VARS FOR ALL_DATA
aa_unaligned_dir = "../selectome/selectome_aa_unaligned_200-50/"
aa_unaligned_files = os.listdir(aa_unaligned_dir)
nt_unaligned_dir = "../selectome/selectome_nt_unaligned_200-50/"
nt_aligned_files = os.listdir(nt_unaligned_dir)

comma = ","
aa_csvfile = "aa_newdata_properties.csv" ## correct extenstion!
nt_csvfile = "nt_newdata_properties.csv"
aa_outfile = open(aa_csvfile, "w")
nt_outfile = open(nt_csvfile, "w")
# will fix headers later
aa_outfile.write("name,number_of_sequences,min_seq_length,max_seq_length,mean_seq_length,standev_seq_length, tree_length,\n")
nt_outfile.write("name,number_of_sequences,min_seq_lengt,max_seq_lengt,mean_seq_length,standev_seq_length\n")

#### Dendropy code!
# For aa aligned a1 files
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
                #print(aa_output_tree_file)
                if os.path.exists(aa_output_tree_file):
                    print(aa_output_tree_file)
                    cmd = "FastTree -nosupport -quiet " + aa_path_to_alignments + name + "/" + str(a1) + " > " + aa_output_tree_file
                    ### run the tree
                    exit_code = os.system(cmd)
                    assert(exit_code == 0), "bad fasttree"
                    try:   
                        aa_tree = dendropy.Tree.get(
                        path=aa_output_tree_file,
                        schema="newick")  
                        print("tree length is" + aa_tree.length())
                        print("-------------------------------------------------------")
                        aa_pdc = aa_tree.phylogenetic_distance_matrix()
                        print(pdc.mean_pairwise_distance())
                    except:
    
                        continue
                    
                    
                    
          
          
          
          
                    
                    
aa_outfile.close()
nt_outfile.close()