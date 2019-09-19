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

fasta_dir = "data/"
all_files = os.listdir(fasta_dir)

comma = ","
csvfile = "data_properties.csv" ## correct extenstion!
outfile = open(csvfile, "w")
outfile.write("name,number_of_sequences\n")

#print(all_files)

#all_fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        # collect information
        name = file.rstrip(".fasta")
        #print("name:", name)
        fasta_records = list(SeqIO.parse(fasta_dir + file, "fasta"))
        #print(fasta_records)
        
        numseq = len(fasta_records)
        #print(numseq)
        
        ##### MORE INFORMATION IS COLLECTED HERE ###
        
        
        # save information
        output_string = name + comma + str(numseq) + "\n"
        #print(output_string)
        
        
        
        outfile.write(output_string)
        

    else:
        continue
    

outfile.close()

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





