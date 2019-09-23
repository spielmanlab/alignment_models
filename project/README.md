## Project organization

1. Directories `fasta_files/` and `learning_to_parse/` are for initial code writing and checking. Can virtually be ignored.

2. `make_bootstrap_alignments.py` and `src_make_bootstrap_alignments/` are code to make perturbed alignments. Based on Guidance2 algorithm, we vary guide trees and opening penalty (`unif(1,3)` for MAFFT).

3. `selectome/` contains the database. Inside are `aa` and `nuc` directories that have been degapped for use here, with script `unalign_selectome.sh`

4. `selectome_aa_output/` and `selectome_nt_output/` contains over hundreds of thousands of csv files parsed from unaligned aa and nt Euteleostomi fastas 

5. `one_csv/` contains python script that creates data_properties.csv of all fastas and a dummy `data` folder that contains fake `fastas` 

6. `all_aa_200-50.txt` contains names of files from selectome with no file extensionl

7. `run_iqtree_on_alignment.py` and `run_iqtree_on_alignment_versions.py` contains scripts that runs iqtree on all `aln.fasta` and then parses iqtree information into csv, latter is slightly modified

8. `submit_pipeline.sbatch` is written in BASH, 

9. `posterstuff/` contains materials used to create poster for COURI Symposium 2019
