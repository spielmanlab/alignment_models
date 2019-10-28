import os
import sys
import statistics
from Bio import SeqIO

def combine_all_data(csv_file, path_to_data, data_type,path_to_trees):

    comma = ","
    fas_file_ending = ".fas"
    fasta_name = "fasta"
    newline = "\n"
    header = "name,data_type,num_seq,min_seq_length,max_seq_length,mean_seq_length,stdev_seq_length" + newline
    
    outfile = open(csv_file, "w")
    outfile.write(header)
    
    unaligned_all_data = os.listdir(path_to_data)
    for file in unaligned_all_data:
        #print(file)
        if file.endswith(fas_file_ending):
            #print(file)
            name = file.strip(fas_file_ending)
            #print(name)
            fasta_records = list(SeqIO.parse(path_to_data + file, fasta_name))
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
            
            
            output_string = name + comma + data_type + comma + str(num_sequences) + comma + str(min_dat) + comma + str(max_dat) + comma + str(mean_dat) + comma + str(standard_dev_dat) + newline 
            print(output_string)
            outfile.write(output_string)

            
        
        
        
        
        
        
        


aa_path_to_data = "../selectome/selectome_aa_unaligned_200-50/" 
aa_data_type = "aa"   
aa_csv_outfile = "aa_test.csv"   

nt_path_to_data = "../selectome/selectome_nt_unaligned_200-50/"
nt_data_type = "nt"
nt_csv_outfile = "nt_test.csv"


combine_all_data(aa_csv_outfile, aa_path_to_data, aa_data_type)
combine_all_data(nt_csv_outfile,nt_path_to_data,nt_data_type)