## Project organization

1. Directories `fasta_files/` and `learning_to_parse/` are for initial code writing and checking. Can virtually be ignored.

2. `make_bootstrap_alignments.py` and `src_make_bootstrap_alignments/` are code to make perturbed alignments. Based on Guidance2 algorithm, we vary guide trees and opening penalty (`unif(1,3)` for MAFFT).

3. `selectome/` contains the database. Inside are `aa` and `nuc` directories that have been degapped for use here, with script `unalign_selectome.sh`

4. 