"""
From SJS personal zip of the PANDIT database, get all the compatible data.
Name output files to be compatible with Selectome naming (for scripting ease): <NAME>.nt.fas and <NAME>.aa.fas
====> 254 PANDIT alignments
"""

from Bio import SeqIO
import random
import os
import sys

min_seq = 25
min_len = 100
outdir_aa = "PANDIT_AA/"
outdir_nt = "PANDIT_NT/"

path_to_pandit = sys.argv[1]

aa_fastas = [x for x in os.listdir(path_to_pandit) if x.endswith("_aa.fasta")]


ok = 0
for pandit_aa in aa_fastas:

    pandit_name = pandit_aa.split("_")[0]
    pandit_nuc = pandit_name + "_nuc.fasta"
    
    outfile_aa = outdir_aa + pandit_name + ".aa.fas"
    outfile_nuc = outdir_nt + pandit_name + ".nt.fas"
    
    with open(path_to_pandit + pandit_aa, "r") as f:
        aa_recs = list(SeqIO.parse(f, "fasta"))
    aa_names = [str(x.id) for x in aa_recs]
    aa_names.sort()
        
    gapless_aa = {}
    gapless_lengths = []
    for rec in aa_recs:
        aa_seq = str(rec.seq).replace("-", "")
        gapless_aa[str(rec.id)] = aa_seq
        gapless_lengths.append(len(aa_seq))
    conditions_ok = min(gapless_lengths) >= min_len and len(aa_recs) >= min_seq
  
    if conditions_ok:
        if os.path.exists(path_to_pandit + pandit_nuc):
            with open(path_to_pandit + pandit_nuc, "r") as f:
                nuc_recs = list(SeqIO.parse(f, "fasta"))
                nuc_names = [str(x.id) for x in nuc_recs]
                nuc_names.sort()
                
                ## same nuc and aa records
                if (aa_names == nuc_names):
                    gapless_nuc = {}
                    for rec in nuc_recs:
                        nuc_seq = str(rec.seq).replace("-", "")
                        gapless_nuc[str(rec.id)] = nuc_seq
                        
                        corresponding_aa_len = len( gapless_aa[str(rec.id)] )
                        if corresponding_aa_len*3 != len(nuc_seq):
                            print(pandit_name, "Incompatible nuc/aa")
                            continue
                    
                    ##### Here, fully checked nt and aa. Save to files
                    with open(outfile_aa, "w") as f:
                        for record in gapless_aa:
                            f.write(">" + str(record) + "\n" + str(gapless_aa[record]) + "\n")
                    with open(outfile_nuc, "w") as f:
                        for record in gapless_nuc:
                            f.write(">" + str(record) + "\n" + str(gapless_nuc[record]) + "\n")
                    
                    ok += 1
                    

                else:
                    print(pandit_name, "Names don't match")
                    continue
        else:
            print(pandit_name, "No nuc file")
            continue
    else:
        print(pandit_name, "Conditions not met")
        continue
    

print("\n\n")
print("------------TOTAL------------")
print(ok)
                    
                    
                    
                    
                    
                    