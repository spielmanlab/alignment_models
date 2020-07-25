"""
From SJS personal zip of the PANDIT database, get all the compatible data.
MUST sed OUT THE GAPS AFTER RUNNING THIS!!! (below, I have gsed as my GNU instead of BSD default on Mac)
gsed -i "s/-//g" PANDIT_AA/*
gsed -i "s/-//g" PANDIT_NT/*
"""

from Bio import SeqIO
import random
import os
import sys

min_seq = 20
max_seq = 1000
min_len = 100  ## AA length
max_len = 5000 ## AA length
outdir_aa = "PANDIT_AA/"
outdir_nt = "PANDIT_NT/"

path_to_pandit = sys.argv[1]

aa_fastas = [x for x in os.listdir(path_to_pandit) if x.endswith("_aa.fasta")]

contenders_sites = {}
contenders_seqs  = {}
contenders = []

for pandit_aa in aa_fastas:

    pandit_name = pandit_aa.split("_")[0]
    pandit_nuc = pandit_name + "_nuc.fasta"
    
    with open(path_to_pandit + pandit_aa, "r") as f:
        aa_recs = list(SeqIO.parse(f, "fasta"))
    nseq = len(aa_recs)
    nsites = len(aa_recs[0])
    aa_names = [str(x.id) for x in aa_recs]
    aa_names.sort()
    
    seq_ok = nseq >= min_seq and nseq <= max_seq
    len_ok = nsites >= min_len and nsites <= max_len
    
    
    if seq_ok and len_ok:
        if os.path.exists(path_to_pandit + pandit_nuc):
            with open(path_to_pandit + pandit_nuc, "r") as f:
                nuc_recs = list(SeqIO.parse(f, "fasta"))
                nuc_names = [str(x.id) for x in nuc_recs]
                nuc_names.sort()
                
                ## FINAL MATCH CONDITION
                if (aa_names == nuc_names):
                    os.system("cp " + path_to_pandit+"/" + pandit_nuc + " " + outdir_nt)
                    os.system("mv " + outdir_nt + pandit_nuc + " " + outdir_nt + pandit_nuc.replace("nuc", "nt"))
                    os.system("cp " + path_to_pandit+"/" + pandit_aa + " " + outdir_aa)
                    
                    
                    
                    
                    
                    
                    
                    