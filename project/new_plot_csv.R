library(tidyverse)

## This function converts a directory of CSV files containing model selection information into a single tibble for all replicates
## NOTE: Assumes that the following headers are in each CSV: No.,Model,-LnL,df,AIC,AICc,BIC
## NOTE: Assumes each file is named <name>_alnversion_<number>_models.csv
process_all_csv <- function(path_to_csv)
{
  # List of all csv files in the given directory
  files <- dir(path = path_to_csv, pattern = "*.csv")
  tibble(filename = files) %>%
    mutate(file_contents = map(filename,
                               ~ read_csv(file.path(path_to_csv, .)))) %>%
    unnest() %>%
    separate(filename, c("name", "dummy", "number", "dummy2"), sep="_") %>%
    dplyr::select(-dummy, -dummy2, -No., -`-LnL`, -df) %>%
    gather(ic_type, ic_value, AIC, AICc, BIC) %>%
    group_by(name, number, ic_type) %>%
    mutate(ic_rank = rank(ic_value)) %>%
    filter(ic_rank == 1) %>%
    ungroup() %>%
    dplyr::select(name, number, Model, ic_type) -> ranked_models
  ranked_models
  
}

aa_path <- "selectome_aa_output/"
nt_path <- "selectome_nt_output/"
aa_ranked_models <- process_all_csv(aa_path)
nt_ranked_models <- process_all_csv(nt_path)


aa_ranked_models %>%
  ggplot(aes(x = Model, fill = Model)) + geom_bar() + theme_classic() + theme(legend.position = "none") + facet_grid(name~ic_type) 

nt_ranked_models %>%
  ggplot(aes(x = Model, fill = Model)) + geom_bar() + theme_classic() + theme(legend.position = "none") + facet_grid(name~ic_type) 









