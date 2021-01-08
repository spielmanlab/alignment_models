import os
import sys
from Bio import SeqIO
import statistics

path_to_data = sys.argv[1]
if not path_to_data.endswith("/"):
    path_to_data += "/"

outstring = "dataset,name,datatype,nseq,mean_nsites\n"
subdirs = [x for x in os.listdir(path_to_data) if os.path.exists(path_to_data + x) and "Icon" not in x]
#print(subdirs)
for subdir in subdirs:
    if "Drosophila" in subdir:
        dataset = "Drosophila"
    elif "Euteleostomi" in subdir:
        dataset = "Euteleostomi"
    else:
        dataset = "PANDIT"
    #print(path_to_data + subdir)
    dataset_dirs = [x for x in os.listdir(path_to_data + subdir) if "Icon" not in x]
    #print(dataset_dirs)
    for dataset_dir in dataset_dirs:
        #print(dataset_dir)
        full_path = path_to_data + "/" + subdir + "/" + dataset_dir + "/"
        fasta_file = [x for x in os.listdir(full_path) if x.endswith("fasta")][1]
        print(full_path+fasta_file)
        
        records = list(SeqIO.parse(full_path + fasta_file, "fasta"))
        nseq = str(len(records))
        mean_nsites = str(statistics.mean([len( str(x.seq).replace("-","")) for x in records]))
        
        rawname = fasta_file.replace(".fasta", "")
        if dataset == "PANDIT":
            name = rawname.split("_")[0]    
            dtype = rawname.split("_")[1] 
        else:
            name = rawname.split(".")[0] 
            dtype = rawname.split(".")[2].split("_")[1]
        
        outstring += ",".join( [dataset, name, dtype, nseq, mean_nsites]  ) + "\n"
        #print(outstring)
        
with open("../results/nsites_nseqs.csv", "w") as f:
    f.write(outstring.strip())