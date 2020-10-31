library(seqinr)
library(tidyverse)

ref_aln <- 50
prefix <- "/Users/spielman/googledrive/data_alignment_models/all_alignments/"
tribble(~dataset,~nseq,~nsites) -> aln_info


big_paths <- c("perturbed_alignments_Drosophila_AA",
               "perturbed_alignments_Euteleostomi_AA",
               "perturbed_alignments_PANDIT_AA")
               
               
for (big_path in big_paths){

  small_paths <- list.files(file.path(prefix,big_path))

  for (small_path in small_paths)
  {
    if (str_detect(small_path, "Icon")) next
    
    fasta_name <- file.path(prefix, big_path, small_path, paste0(small_path, "_50.fasta") )    
    aln <- read.fasta(fasta_name)
    nseq <- length(aln)
    nsites <- length(aln[[1]])
    
    aln_info %>%
      bind_rows(
        tribble(~dataset,~nseq,~nsites,
                small_path, nseq, nsites)
      ) -> aln_info
  }
}

aln_info %>% 
  separate(dataset, into=c("id", "dataset", "trash"), sep = "\\.") %>% 
  replace_na(list(dataset = "PANDIT")) %>%
  mutate(id = str_replace(id, "_AA","")) %>%
  select(-trash) -> aln_info_clean 

write_csv(aln_info_clean, "../results/reference_alignments_nsites_nseq.csv")

## Summary statistics
aln_info_clean %>%
  group_by(dataset) %>%
  summarize(mean_nseq = mean(nseq),
            sd_nseq   = sd(nseq),
            mean_nsites = mean(nsites),
            sd_nsites   = sd(nsites),
            min_nseq  = min(nseq),
            max_nseq  = max(nseq),
            min_nsites  = min(nsites),
            max_nsites  = max(nsites))
#  dataset mean_nseq sd_nseq mean_nsites sd_nsites min_nseq max_nseq min_nsites  max_nsites
#  <chr>       <dbl>   <dbl>       <dbl>     <dbl>    <int>    <int>      <int>       <int>
#1 Drosop…      14.1   11.8        1189.      734.        6      135        188        4853
#2 Eutele…      33.5    9.33        676.      436.        7       63        183        3834
#3 PANDIT       44.4   27.4         279.      141.       25      255        116         974
