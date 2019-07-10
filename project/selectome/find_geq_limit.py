## Selectome where all >=limit long
from Bio import SeqIO
import os

lenlimit = 200
nseqlimit = 50
aain = "selectome_v06_Euteleostomi-aa_unmasked-UNALIGNED/"
ntin = aain.replace("aa", "nt")
aaout = "selectome_aa_unaligned_" + str(lenlimit) + "-" + str(nseqlimit)+ "/"
ntout = aaout.replace("aa", "nt")
os.system("mkdir -p " + aaout)
os.system("mkdir -p " + ntout)
os.system("rm " + aaout + "*")
os.system("rm " + ntout + "*")



fasfiles = [x for x in os.listdir(aain) if x.endswith("fas")]

for aafas in fasfiles:
    save=True
    rec = list(SeqIO.parse(aain + aafas, "fasta"))
    if (len(rec)) < nseqlimit:
        save = False
        print("NO")
        continue
    for record in rec:
        if len(str(record.seq)) < lenlimit:
            save=False
            print("NO")
            break
    if save:      
        os.system("cp " + aain + aafas + " " + aaout)
        os.system("cp " + ntin + aafas.replace("aa", "nt") + " " + ntout)
        print("YES")

