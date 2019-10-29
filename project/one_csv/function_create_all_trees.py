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


file_ending = ".fas_alnversions"
file_a1ending = "alnversion_1.fasta"

# def make_trees(path_to_alignment = None, path_to_output_file = None, FT_command = None):
#def make_trees(**kwargs):


def make_trees(path_to_alignment, path_to_output_file, data_type):

    """
    assert (data_type in ["nt", "aa"]), "wrong data_type arg"
    assert that the path_to_output_tree file isn't empty 
    """
    allfiles = os.listdir(path_to_alignment)
    #print(allfiles)
    for file in allfiles:
        name = str(file)
        x = name.endswith(file_ending)
        if x:
            alignment_files = os.listdir(path_to_alignment + file)
            for alnversion_1 in alignment_files:
                a1_file_ending = alnversion_1.endswith(file_a1ending)
                if a1_file_ending:
                    #print(alnversion_1)
                    output_tree_file = path_to_output_file + alnversion_1 + ".tree"
                    if os.path.exists(output_tree_file):
                        if os.path.getsize(output_tree_file) > 0:
                            continue
                    #print(output_tree_file)
                    if data_type == "nt":
                        cmd = "FastTree -nt -gtr -nosupport -quiet " + path_to_alignment + str(name) + "/" + str(alnversion_1) + " > " + output_tree_file             
                        print(name)
                        print(cmd)
                        exit_code = os.system(cmd)
                        assert(exit_code == 0), "Bad FastTree for nt"
                            
                    elif data_type == "aa":
                        cmd2 = "FastTree -nosupport -quiet " + path_to_alignment + str(name) + "/" + str(alnversion_1) + " > " + output_tree_file
                        print(cmd2)
                        exit_code2 = os.system(cmd2)
                        assert(exit_code2 == 0), "Bad FastTree for aa"  
                      
                    else:
                        raise AssertionError("data_type arg must be either nt or aa")
                        assert(os.path.getsize(output_tree_file) > 0), "tree file size is 0"
                    

    return 0
    

nt_path_to_alignments = "../selectome_nt_output/"
aa_path_to_alignments = "../selectome_aa_output/"



path_to_aa_output_trees = aa_path_to_alignments + "alnversion1_trees/"
os.system("mkdir -p " + path_to_aa_output_trees)
path_to_nt_output_trees = nt_path_to_alignments + "alnvers1_trees/"
os.system("mkdir -p " + path_to_nt_output_trees)

nt_data_type = "nt"
aa_data_type = "aa"

make_trees(aa_path_to_alignments, path_to_aa_output_trees, aa_data_type)
make_trees(nt_path_to_alignments, path_to_nt_output_trees, nt_data_type)