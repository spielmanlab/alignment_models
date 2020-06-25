library(tidyverse)
#will start with just one .csv file and then continue with all
path_drossaa <- "results/Drosophila_AA_alignment_scores.csv"
dros_aa <-read_csv(path_drossaa)

i<-0
while(i<=50) {
  dros_aa %>%
    group_by(dataset,ref_num,est_num,sp,tc) 
    
}
  
stat_csv <- dros_aa %>%
  select(-species,-datatype) %>%
  group_by(dataset,ref_num,est_num,sp,tc) %>%
  tally() %>%
  select()
