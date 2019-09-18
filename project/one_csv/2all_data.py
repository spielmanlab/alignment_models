from Bio import SeqIO
import os
import statistics

fasta_dir = "../one_csv/data/"
all_files = os.listdir(fasta_dir)
print(all_files)

all_fasta_files = []
for file in all_files:
    if file.endswith(".fasta"):
        all_fasta_files.append(file)
print (all_fasta_files)

csvfile = fasta_dir + "one_csv"
outfile = open(csvfile, "w")

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





