"""
Read in all AA fasta files and convert back to NT, given the true NT data
"""

from Bio import Seq
from Bio import SeqIO
from Bio.Alphabet import generic_dna
import os
import sys

def back_translate(protseq, nucseq):
    '''Back translate an individual sequence''' 
    nucaln = ''
    start = 0; end = 3;
    for amino in protseq:
        if amino == '-':
            codon = '---'
        else:
            codon = nucseq[start:end]
            start += 3
            end += 3
        nucaln += codon
    assert(len(protseq)*3 == len(nucaln)), "Back-translation failed."
    return nucaln
  


path_to_aa  = sys.argv[1]
original_nt = sys.argv[2]
outpath     = sys.argv[3]

### Create a dictionary for the NT sequences 
nt_records_dict = {}
with open(original_nt, "r") as f:
    nt_records = list(SeqIO.parse(f, "fasta"))
for rec in nt_records:
    nt_records_dict[ str(rec.id) ] = str(rec.seq)

### Loop over each aa alignment to produce its codon version
aa_fasta = [x for x in os.listdir(path_to_aa) if x.endswith("fasta")]
for aa_alnfile in aa_fasta:
    codon_aln = {}
    codon_name = aa_alnfile.replace("AA", "CODON")
    codon_alnfile = outpath + codon_name
    print(codon_alnfile)
    with open(path_to_aa + aa_alnfile, "r") as f:
        aa_aln = list(SeqIO.parse(f, "fasta"))
        for record in aa_aln:
            codon_seq = back_translate( str(record.seq), nt_records_dict[str(record.id)] )
            codon_aln[str(record.id)] = codon_seq
        
    with open(codon_alnfile, "w") as f:
        for record in codon_aln:
            f.write(">" + str(record) + "\n" + str(codon_aln[record]) + "\n")
        
    