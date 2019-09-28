from Bio import SeqIO
import os
import statistics
import glob
import sys


"""
This is pseudocode! It is code in HUMAN LANGUAGE syntax, not python (or whatever language) syntax.

get all file names (all_files)
loop over all file names
    check: is a fasta?
    if yes:
        collect information from the fasta: name, numseq, minlength, maxlength, meanlength, sdlength
        write information to the output file
    if no:
        move on to the next file
"""

### DATATYPE "nt" or "aa"

aa_csvfile = "aa_data_properties.csv" ## correct extenstion!
aa_outfile = open(aa_csvfile, "w")
aa_outfile.write("name,number_of_sequences,min,max,mean,standev\n")

comma = ","
aa_fasta_dir = ("../selectome_aa_output/")
for fasta in glob.glob("../selectome_aa_output/**/*.fasta"):
    #print(fasta)
    
    
    name = fasta.strip(".fasta" + "/selectome_aa_output")
    print(name)

    fasta_records = list(SeqIO.parse(aa_fasta_dir + fasta, "fasta"))
    #print(fasta_records[0])
    
    
    num_seq = len(fasta_records)
    #print(num_seq)
    
    rec_lengths = []
    for rec in fasta_records:
        nogap = rec.ungap("-")
        seqs = nogap.seq
        x = len(seqs)
        rec_lengths.append(x)
    print(rec_lengths)
        
    mins = min(rec_lengths)
    maxes = max(rec_lengths)
    means = statistics.mean(rec_lengths)
    standevs = statistics.stdev(rec_lengths)
    
    aa_output_string = name + comma + str(num_seq) + comma + str(mins) + comma + str(maxes) + comma + str(means) + comma + str(standevs) +"\n"

    #aa_outfile.write(aa_output_string)
    
aa_outfile.close()




#comma = ","
#csvfile = "aa_data_properties.csv" ## correct extenstion!

#outfile = open(csvfile, "w")
#outfile.write("name,number_of_sequences,min,max,mean,standev\n")

#for file in aa_all_files:
   # if file.endswith(".fasta"):
        # collect information
    #    name = file.rstrip(".fasta")
     ##  aa_fasta_records = list(SeqIO.parse(aa_fasta_dir + file, "fasta"))
        #print(fasta_records)
        





#outfile.close()