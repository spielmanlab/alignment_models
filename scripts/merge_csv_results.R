# Modifed by SJS and originally written by MM (see her original at bottom)
# Merge a bunch of CSVs

### Run at various points in pipeline:
##### Rscript merge_csv_results.R ../results/selected_models_output/ ../results/all_selected_models.csv
##### Rscript merge_csv_results.R ../results/pairwise_distances/ ../results/pairwise_hamming_distances.csv
##### Rscript merge_csv_results.R ../results/alignment_scores/ ../results/all_alignment_scores.csv

library(tidyverse)
args <- commandArgs(trailingOnly=TRUE)

csv_directory <- args[1]
output_file   <- args[2]

csv_files <- dir(path=csv_directory,pattern="*.csv")
tibble(filename=csv_files) %>%
  mutate(file_contents=map(filename,
                           ~ read_csv(file.path(csv_directory, .)))) %>%
  unnest(cols = c(file_contents)) %>%
  select(-filename) -> csvdf
write_csv(csvdf,output_file)




############ Below written by MM: ###############
#csv_directory <- "../results/selected_models_output/"
# #dir() - lists all the files in a directory 
#csv_files <- dir(path=csv_directory,pattern="*.csv")
#afile_tibble <- tibble(filename=csv_files) 
#csvdf <- afile_tibble %>%
#  mutate(file_contents=map(filename,
#                           ~ read_csv(file.path(csv_directory, .)))) %>%
#  unnest() 
#
#write_csv(csvdf,"../results/all_selected_models.csv")

