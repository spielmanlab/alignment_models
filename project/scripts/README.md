## Scripts Organization

1. `merge_all_all_selectome_csvs.r` is an R script that creates a `.csv` file that contains all the data from `output_selectome/` and lives in `../results/` and is named `all_selectome_output_csvs.csv`

2. `csv_tidydata_progress.rmd` is an R Markdown script that contains progress from wrangling the data from `all_selectome_output_csvs.csv`. The data is also being plotted, and is in a constant work in progress.

3. `run_iqtree_on_alignment_versions.py` is a Python script that works within Terminal and iqtree, running the iqtree program on alignments.