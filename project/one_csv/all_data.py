from Bio import SeqIO
import os
import statistics
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

aa_fasta_dir = "../selectome/selectome_aa_unaligned_200-50/"
aa_all_files = os.listdir(aa_fasta_dir)

nt_fasta_dir = "../selectome/selectome_nt_unaligned_200-50/"
nt_all_files = os.listdir(nt_fasta_dir)

print(aa_all_files)


comma = ","
aa_csvfile = "aa_data_properties.csv" ## correct extenstion!
nt_csvfile = "nt_data_properties.csv"
aa_outfile = open(aa_csvfile, "w")
nt_outfile = open(nt_csvfile, "w")
aa_outfile.write("name,number_of_sequences,min_seq_length,max_seq_length,mean_seq_length,standev_seq_length\n")
nt_outfile.write("name,number_of_sequences,min_seq_lengt,max_seq_lengt,mean_seq_length,standev_seq_length\n")


#print(all_files)

#all_fasta_files = []
for file in aa_all_files:
    if file.endswith(".fas"):
        # collect information
        name = file.rstrip(".fas")
        #print("name:", name)
        fasta_records = list(SeqIO.parse(aa_fasta_dir + file, "fasta"))
        #print(fasta_records)
        
        numseq = len(fasta_records)
        #print(numseq)
        
        
        ##### MORE INFORMATION IS COLLECTED HERE ###
        rec_lens = []
        
        for rec in fasta_records:
           #print(rec)
           #print(rec.seq)
           x = (len(rec.seq))
           rec_lens.append(x)
           
        #print(rec_lens)
        minss = min(rec_lens)
        print(minss)
        maxes = max(rec_lens)
        #print(maxes)
        means = statistics.mean(rec_lens)
        #print(means)
        standevs = statistics.stdev(rec_lens)
        #print(standevs)
     
     
        # save information
        aa_output_string = name + comma + str(numseq) + comma + str(minss) + comma + str(maxes) + comma + str(means) + comma + str(standevs) +"\n"
        #print(output_string)
        
        
        aa_outfile.write(aa_output_string)
        
    else:
        continue
        
        
#all_fasta_files = []
for file in nt_all_files:
    if file.endswith(".fas"):
        # collect information
        name = file.rstrip(".fas")
        #print("name:", name)
        fasta_records = list(SeqIO.parse(nt_fasta_dir + file, "fasta"))
        #print(fasta_records)
        
        numseq = len(fasta_records)
        #print(numseq)
        
        
        ##### MORE INFORMATION IS COLLECTED HERE ###
        rec_lens = []
        
        for rec in fasta_records:
           #print(rec)
           #print(rec.seq)
           x = (len(rec.seq))
           rec_lens.append(x)
           
        #print(rec_lens)
        minss = min(rec_lens)
        print(minss)
        maxes = max(rec_lens)
        #print(maxes)
        means = statistics.mean(rec_lens)
        #print(means)
        standevs = statistics.stdev(rec_lens)
        #print(standevs)
     
     
        # save information
        nt_output_string = name + comma + str(numseq) + comma + str(minss) + comma + str(maxes) + comma + str(means) + comma + str(standevs) +"\n"
        print(nt_output_string)
        
        
        nt_outfile.write(nt_output_string)
        
    else:
        continue
    

aa_outfile.close()
nt_outfile.close()

sys.exit() ## only for now until you get above code FULLY working.










###########################################################################################
###########################################################################################


comma = ","

names = []
numberseq = []
recs = []
mins = []
maxs = []
means = []
stdevs = []

for file in all_fasta_files:

    fastafile = fasta_dir + file
    
    fasta_records = list(SeqIO.parse(fastafile, "fasta"))
    #print(fasta_records)
    x = file.rstrip(".fasta")
    names.append(x)
    z = len(fasta_records)
    numberseq.append(z)
    for rec in fasta_records:
        x = (len(rec))
        recs.append(x) 
        
for file in all_fasta_files:       
    a = min(recs)
    mins.append(a)
    b = max(recs)
    maxs.append(b)
    c = statistics.mean(recs)
    means.append(c)
    d = statistics.stdev(recs)
    stdevs.append(d)
    
parsingdict = {"names":names, "numbersequences":numberseq, "min":mins, "max":maxs, "mean":means, "standardev":stdevs}

print(parsingdict.values())

for val in parsingdict.values():
    dataline = comma.join(map(str, val)) + "\n"
    

outfile.write(dataline)

outfile.close()





