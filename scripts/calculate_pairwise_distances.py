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

    path_to_alignments = sys.argv[1]
    dataset            = sys.argv[2]
    datatype           = sys.argv[3]
    
    if not path_to_alignments.endswith("/"):
        path_to_alignments += "/"
    
    inmafft = dataset+datatype+"-in.fasta"
    outmafft = dataset+datatype+"-out.fasta"
    
    outfile = "pairwise_hamming_" + dataset + "_" + datatype + ".csv"
    outstring = "dataset,datatype,mean_hamming,median_hamming,sd_hamming\n"
    all_aln_dir = [x for x in os.listdir(path_to_alignments) if os.path.isdir(os.path.join(path_to_alignments,x))]
    for aln_dir in all_aln_dir:
        print(aln_dir)
        reference = path_to_alignments + aln_dir+"/" + aln_dir + "_50.fasta"
        align = AlignIO.read(reference, "fasta")
        record_pairs = list(itertools.combinations(align, 2))
        distances = []
        for pair in record_pairs:
            with open(inmafft, "w") as f:
                f.write(">" + str(pair[0].id) + "\n" + str(pair[0].seq) + "\n" + ">" + str(pair[1].id) + "\n" + str(pair[1].seq))
            diditmafft = os.system("mafft --quiet " + inmafft + " > " + outmafft)             
            assert(diditmafft == 0)
            distances.append(hamming_on_pairwise(inmafft))
        
        vals = [statistics.mean(distances),statistics.median(distances),statistics.stdev(distances)]
        outstring += dataset + "," + datatype + "," + ",".join([ str(x) for x in vals ]) + "\n"
        break
        
    with open(outfile, "w") as f:
        f.write(outstring.strip())
        
    # cleanup
    os.remove(inmafft)
    os.remove(outmafft)
        
    
main()