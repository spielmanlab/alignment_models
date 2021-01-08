import os
import sys
from Bio import AlignIO
import itertools
import statistics



def hamming_on_pairwise(file):
    aln = AlignIO.read(file, "fasta")
    r1 = str(aln[0].seq)
    r2 = str(aln[1].seq)
    diff = sum([1 for x in range(len(r1)) if r1[x] != r2[x]])
    return (diff/len(r1))
    

def main():

    fasta_file         = sys.argv[1]
    path_to_alignments = sys.argv[2]
    output_path        = sys.argv[3]
    
    rawname = fasta_file.replace("_50.fasta","")
    print(rawname)
    if "PF" in rawname:
        sp = rawname.split("_")
        dataname = sp[0]
        datatype = sp[1]
        dataset = "PANDIT"
    else:
        sp = rawname.split("_")
        rawname2 = sp[0].split(".")
        datatype = sp[1]
        dataname = rawname2[0]
        dataset = rawname2[1]
    
    inmafft = rawname + "-inmafft.txt"
    outmafft = rawname + "-outmafft.txt"
    
    outfile = output_path + "pairwise_hamming_" + rawname + ".csv"
    outstring = "dataname,dataset,datatype,mean_hamming,median_hamming,sd_hamming\n"
    
    align = AlignIO.read(path_to_alignments + "/" + fasta_file, "fasta")
    record_pairs = list(itertools.combinations(align, 2))
    distances = []
    for pair in record_pairs:
        with open(inmafft, "w") as f:
            f.write(">" + str(pair[0].id) + "\n" + str(pair[0].seq).replace("-", "") + "\n" + ">" + str(pair[1].id) + "\n" + str(pair[1].seq).replace("-", ""))
        diditmafft = os.system("mafft --quiet " + inmafft + " > " + outmafft)             
        assert(diditmafft == 0)
        distances.append(hamming_on_pairwise(outmafft)) 
    
    vals = [statistics.mean(distances),statistics.median(distances),statistics.stdev(distances)]
    with open(outfile, "w") as f:
        f.write("dataname,dataset,datatype,mean_hamming,median_hamming,sd_hamming\n")
        f.write(dataname + "," + dataset + "," + datatype + "," + ",".join([ str(x) for x in vals ]))
            
    # cleanup
    os.remove(inmafft)
    os.remove(outmafft)
    
main()