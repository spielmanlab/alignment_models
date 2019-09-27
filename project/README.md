## Project organization

1. Directories `fasta_files/` and `learning_to_parse/` are for initial code writing and checking. Can virtually be ignored.

2. `make_bootstrap_alignments.py` and `src_make_bootstrap_alignments/` are code to make perturbed alignments. Based on Guidance2 algorithm, we vary guide trees and opening penalty (`unif(1,3)` for MAFFT).

3. `selectome/` contains the database. Inside are `aa` and `nuc` directories that have been degapped for use here, with script `unalign_selectome.sh`

4. `selectome_aa_output/` and `selectome_nt_output/` contains over hundreds of thousands of csv files parsed from unaligned aa and nt Euteleostomi fastas 

5. `one_csv/` contains python script `all_data.py` that creates `data_properties.csv` of all fastas and a dummy `data` folder that contains fake `fastas` to test. `2all_data.py` contains testing to parse actual files from `selectome_aa_output/`.

6. `aa_ranked_models.csv` and `nt_ranked_models.csv` contain models ranked according to information criterion. `all_aa_200-50.txt` contains names of files from selectome with no file extension (don't know if needed or not)

7. `run_iqtree_on_alignment.py` and `run_iqtree_on_alignment_versions.py` contains scripts that runs iqtree on all fasta alignments and then parses iqtree information into .csv file

8. `submit_pipeline.sbatch` is written in BASH, used to run all alignments+Guidance2 on Rowan Computing Cluster  

9. `posterstuff/` contains materials used to create poster for COURI Symposium 2019 (can virtually be ignored)

10. `project` is the current directory where this README lives, contains all that is relevant

