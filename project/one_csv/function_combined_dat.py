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
    header = "name,data_type,num_seq,min_seq_length,max_seq_length,mean_seq_length,stdev_seq_length,tree_length,mean_pairwise_distance" + newline
    
    outfile = open(csv_file,"w")
    outfile.write(header)
    
    unaligned_all_data = os.listdir(path_to_data)
    
    
    for file in unaligned_all_data:
        #print(file)
        if file.endswith(fas_file_ending):
            #name = file.strip(fas_file_ending)
            associated_tree = path_to_trees + file + "_alnversion_1.fasta.tree"            
            #print(associated_tree)
            
            try:
                dendropy_tree = dendropy.Tree.get(
                    path = associated_tree,
                    schema = "newick")
                #print(dendropy_tree)
                
            except:
                continue
            
            treelength = dendropy_tree.length()
            #print(treelength)
            #print("----------------------------------------------------------------")
            pdc = dendropy_tree.phylogenetic_distance_matrix()
            meanpairwise = pdc.mean_pairwise_distance()
            #print(meanpairwise)
            
            name = file.strip(fas_file_ending)
            #print(name)
            fasta_records = list(SeqIO.parse(path_to_data + file, fasta_string))
            #print(fasta_records)
            num_sequences = len(fasta_records)
            #print(num_sequences)
            
            record_lengths = [len(rec.seq) for rec in fasta_records]
            #print(rec_lens)
            
            min_dat = min(record_lengths)
            #print(min_dat)
            max_dat = max(record_lengths)
            #print(max_dat)
            mean_dat = statistics.mean(record_lengths)
            #print(mean_dat)
            standard_dev_dat = statistics.stdev(record_lengths)    
            #print(standard_dev_dat)
            
            output_string = name + comma + data_type + comma + str(num_sequences) + comma + str(min_dat) + comma + str(max_dat) + comma + str(mean_dat) + comma + str(standard_dev_dat) + comma + str(treelength) + comma + str(meanpairwise) + newline 
            print(output_string)
            
            outfile.write(output_string)
            
    outfile.close()

    
aa_path_to_alignments = "../selectome_aa_output/"
path_to_aa_output_trees = aa_path_to_alignments + "alnversion1_trees/"
aa_csv_file = "test_aa.csv"
aa_path_to_data = "../selectome/selectome_aa_unaligned_200-50/" 
aa_data_type = "aa"   

        
combine_data(aa_csv_file,aa_path_to_data,aa_data_type,path_to_aa_output_trees)
        
        
        