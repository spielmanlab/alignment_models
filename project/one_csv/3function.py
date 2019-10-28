import os
import sys
import statistics
from Bio import SeqIO
import dendropy

### loop over alignment output (names, first grab the tree associated with that, then loop for the other files)

def combine_data(csv_file,path_to_data,data_type,path_to_trees):
    comma = ","
    fas_file_ending = ".fas"
    fasta_string = "fasta"
    newline = "\n"
    header = "name,data_type,num_seq,min_seq_length,max_seq_length,mean_seq_length,stdev_seq_length" + newline
    
    outfile = open(csv_file,"w")
    outfile.write(header)
    
    unaligned_all_data = os.listdir(path_to_data)
    
    
    for file in unaligned_all_data:
        #print(file)
        if file.endswith(fas_file_ending):
            #name = file.strip(fas_file_ending)
            associated_tree = path_to_trees + file + "_alnversion_1.fasta.tree"            
            print(associated_tree)
            
            try:
                dendropy_tree = dendropy.Tree.get(
                    path = associated_tree,
                    schema = "newick")
                print(dendropy_tree)
                
            except:
                continue
                
        
            
            
          #   
#             if name:
#                 trees = os.listdir(path_to_trees)
#                 print(trees[0])
#                 sys.exit()
#                 for tree in trees:
#                     dendropy_tree_get_file = path_to_trees + tree
#                     print(dendropy_tree_get_file)
#                     dendropy_tree = dendropy.Tree.get(
#                         path = dendropy_tree_get_file,
#                         schema = "newick")
#                     print(dendropy_tree)
#                     sys.exit()
#                     treelength = dendropy_tree.length()
#                     print(treelength)

    
aa_path_to_alignments = "../selectome_aa_output/"
path_to_aa_output_trees = aa_path_to_alignments + "alnversion1_trees/"
aa_csv_file = "test_aa.csv"
aa_path_to_data = "../selectome/selectome_aa_unaligned_200-50/" 
aa_data_type = "aa"   




        
combine_data(aa_csv_file,aa_path_to_data,aa_data_type,path_to_aa_output_trees)
        
        
        