Repository associated with the manuscript, [**Relative model selection of evolutionary substitution models can be sensitive to multiple sequence alignment uncertainty**](https://bmcecolevol.biomedcentral.com/articles/10.1186/s12862-021-01931-5)
+ Stephanie J. Spielman (corresponding)
+ Molly Miraglia


## Repository Contents

> All variant MSA data is available from this [FigShare repository](https://doi.org/10.6084/m9.figshare.16955257)
> 
+ [`prepare_orthologs/`](https://github.com/spielmanlab/alignment_models/tree/main/prepare_orthologs) contains scripts to obtain orthologs from PANDIT and Selectome databases, in respective subdirectories. Each respective subdirectory also contains _unaligned_ sets of orthologs obtained. 

+ [`scripts/`](https://github.com/spielmanlab/alignment_models/tree/main/scripts) contains analysis scripts to generate data which are generally saved into [`results/`](https://github.com/spielmanlab/alignment_models/tree/main/results)
  + [`batch_scripts/`](https://github.com/spielmanlab/alignment_models/tree/main/scripts/batch_scripts) contains scripts needed to run analyses on _local_ HPC
  + The script [`pipeline.sh`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/pipeline.sh) creates all MSAs and runs model selection as follows:
    + Step 1: Create perturbed alignments
      + Run [`make_bootstrap_alignments.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/make_bootstrap_alignments.py) (uses [`src_make_bootstrap_alignments/`](https://github.com/spielmanlab/alignment_models/tree/main/scripts/src_make_bootstrap_alignments)) to produce all variant MSAs
    +  Step 2: Perform model selection
      + Run [`run_iqtree_on_alignment_versions.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/run_iqtree_on_alignment_versions.py) to produce [`results/selected_models_output/`](https://github.com/spielmanlab/alignment_models/blob/main/results/selected_models_output.tar.bz2) (compressed in repo) which contains a single CSV file per dataset.
      + Run [`merge_csv_results.R`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/merge_csv_results.R) to collate all CSV output to produce [`results/all_selected_models.csv`](https://github.com/spielmanlab/alignment_models/blob/main/results/all_selected_models.csv)
  + The script [`calculate_guidance_scores.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/calculate_guidance_scores.py) calculates GUIDANCE scores and saves to [`results/final_guidance_scores.csv`](https://github.com/spielmanlab/alignment_models/blob/main/results/final_guidance_scores.csv)
  + The script [`calculate_alignment_scores.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/calculate_alignment_scores.py) calculates SP and TC scores using `FastSP.jar` and saves to [`results/alignment_scores/`](https://github.com/spielmanlab/alignment_models/blob/main/results/alignment_scores.tar.bz2) (compressed in repo), and those are files combined with [`merge_csv_results.R`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/merge_csv_results.R) into [`results/all_alignment_scores.csv`](https://github.com/spielmanlab/alignment_models/blob/main/results/all_alignment_scores.csv)
  + The script [`calculate_pairwise_distances.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/calculate_pairwise_distances.py) calculates pairwise edit (Hamming) distances and saves to [`results/pairwise_distances/`](https://github.com/spielmanlab/alignment_models/blob/main/results/pairwise_distances.tar.bz2) (compressed in repo), and those files are combined with [`merge_csv_results.R`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/merge_csv_results.R) into [`results/pairwise_hamming_distances.csv`](https://github.com/spielmanlab/alignment_models/blob/main/results/pairwise_hamming_distances.csv)
  + The script [`calculate_alignment_info.py`](https://github.com/spielmanlab/alignment_models/blob/main/scripts/calculate_alignment_info.py) calculates mean sites and sequences in datasets and saves into [`results/nsites_nseqs.csv`](https://github.com/spielmanlab/alignment_models/blob/main/results/nsites_nseqs.csv)

+ [`analysis/`](https://github.com/spielmanlab/alignment_models/tree/main/analysis) contains all processing, statistical analysis, main text figures, and SI. All can be reproduced with [`run_analysis.R`](https://github.com/spielmanlab/alignment_models/blob/main/analysis/run_analysis.R)
