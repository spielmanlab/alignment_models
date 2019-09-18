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
outfile = (open, csvfile, "w")

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
    print(fasta_records)
    x = file.rstrip(".fasta")
    names.append(x)
    z = len(fasta_records)
    numberseq.append(z)

    for rec in fasta_records:
        c = len(rec)
        recs.append(c)
        print(recs)
        print(statistics.mean(recs))
   


parsingdict = {"names":names, "numbersequences":numberseq, "min":mins, "max":maxs, "mean":means, "standardev":stdevs}

#for names, numberseq, mins, maxs, means, stdevs in zip(*parsingdict.values()):
    # str(var + ",")

print(parsingdict.values())

singular_rec = ([mins[i::len(all_fasta_files)] for i in range(len(all_fasta_files))])
print(min(singular_rec))
stri = comma.join(map(str,singular_rec))

stri2 = stri.replace("[", "")
print(stri2)

outfile.close()
