## Evaluating the robustness of relative model selection to MSA quality

+ `selectome/` contains Drosophila and Euteleostomi *unaligned* orthologs from Selectome, specifically only transcripts labeled as "001"
	+ `selectome/obtain_unalign_selectome.sh` is used to populate this directory

+ `scripts/` contains analysis scripts for processing data. 
	+ The script `pipeline.sh` runs commands in order to perform steps below. It was executed on the Rowan University Computing Cluster using `submit_pipeline.sbatch`.
		+ Step 1: Create perturbed alignments
			+ Run `make_bootstrap_alignments.py` (uses `src_make_bootstrap_alignments`) to produce alignments currently stored in Google Drive
		+ Step 2: Perform model selection
			+ Run `run_iqtree_on_alignment_versions.py` to produce `results/selected_models_output/` which contains a single CSV file per dataset.
			+ Run `merge_selected_models_output.R` to collate all CSV output to produce `results/all_selectome_output_csvs.csv`
		+ Step 3: Score perturbed alignments
			+ Uses FORTHCOMING SCRIPT 
	
+ `results/`
	+ **TODO**: `csv_tidydata_progress.rmd` may need cleanup for presentation purposes. We will return to this.


