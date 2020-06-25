# Load libraries ------------------------------------------------
library(tidyverse)

# FYI: https://style.tidyverse.org/

# Define paths and load data ------------------------------------
dros_aa_scores_file <- "../results/Drosophila_AA_alignment_scores.csv"
dros_aa_scores <-read_csv(dros_aa_scores_file)


# Subset to only comparisons with dataset #50 -------------------
dros_aa_scores %>%
  filter(ref_num == 50 | est_num == 50) %>%
  distinct() -> dros_aa_scores_vs50

# Calculate ...--------------------------------------------------
