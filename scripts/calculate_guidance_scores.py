"""
Modified code from:  https://github.com/sjspielman/alignment_filtering/blob/master/PhyloGuidance/src/scorer.py
"""
from Bio import AlignIO
import numpy as np
import sys
import os

def count_gaps(parsed, alnlen): #parsed = a parsed alignment.
    ## Count the number of gaps in a column and returns a list. Does not give any information as to which positions are gaps.         
    numGaps = []
    for i in range(0,alnlen): #number of sequences            
        findgaps = str(parsed[:,i])
        num = findgaps.count('-')
        numGaps.append(num)
    return numGaps


def process_scores(n, numseq, alnlen, parsed_msa, all_scores):

    numGaps = count_gaps(parsed_msa, alnlen)
    final_scores = np.zeros(alnlen)

    #Normalize scores
    normedscores = np.zeros(alnlen)
    t=0 #taxon counter
    s=0 #entry in row counter
    for taxon in all_scores:
        for score in taxon:
            norm = (numseq - numGaps[s] -1)*n   ## the "-1" is because we can't be comparing it to itself.
            if norm==0 or score==0:
                normedscores[s]=0
            else:
                normedscores[s]=(score/norm)
            s+=1
        final_scores = np.vstack((final_scores, normedscores))
        normedscores=np.zeros(alnlen)
        s=0    
        t+=1
    final_scores = np.delete(final_scores, (0), axis=0)
    
    #index_row = np.arange(1,(alnlen+1),1)
    #final_scores_output = np.vstack((index_row, final_scores))
    #savetxt(allscores_file, final_scores_output, delimiter='\t', fmt='%.3f')
    
    return (final_scores)
    
n_boot = 49
guidance_scorer = "./guidance_score"

final_scores_mean_med_sd = {}


path_to_everything = sys.argv[1]
subpaths = [x for x in os.listdir(path_to_everything) if x.startswith("perturbed")]
for path2 in subpaths:
    j = 0
    full_path2 = os.path.join(path_to_everything, path2) + "/"
    subsubpaths =  [x for x in os.listdir(full_path2) if os.path.isdir(full_path2+x)]
    for dataset_path in subsubpaths:
        j += 1
        print(path2, j)
        # BEGIN #
        msa_path = os.path.join(path_to_everything, path2, dataset_path) + "/"
        overall_name = dataset_path.rstrip("/")
        reference_msa_file = os.path.join(msa_path, overall_name + "_50.fasta")

        with open(reference_msa_file, "r") as f:
            reference_msa_records = AlignIO.read(f, "fasta")
        numseq = len(reference_msa_records)
        alnlen = len(reference_msa_records[0].seq)
        all_scores=np.zeros((numseq, alnlen)) 

        for i in range(1, n_boot+1):
            test_msa_file = reference_msa_file.replace("_50.fasta", "_" + str(i) + ".fasta")
            outfile = "temp.txt"
    
            cmd = " ".join([guidance_scorer, reference_msa_file, test_msa_file, outfile])
            cmdcode = os.system(cmd)
            assert(cmdcode == 0), "error: guidance scoring"
            scores = np.loadtxt(outfile)
            all_scores = all_scores + scores
    
        final_scores = process_scores(n_boot, numseq, alnlen, reference_msa_records, all_scores)
        flat_scores = np.ndarray.flatten(final_scores)
        final_scores_mean_med_sd[overall_name] = [str(np.mean(flat_scores)), str(np.median(flat_scores)), str(np.std(flat_scores))]
        #print(final_mean_scores)
        #print(final_median_scores)
        #print(final_sd_scores)
        #break
        
with open("../results/final_guidance_scores.csv", "w") as f:
    f.write("fullid,mean_guidance_score,median_guidance_score,sd_guidance_score\n")
    for key in final_scores_mean_med_sd:
        thiskey = final_scores_mean_med_sd[key]
        f.write(",".join([key, thiskey[0], thiskey[1], thiskey[2]]) + "\n")
    
    
    
    
    
    
    
