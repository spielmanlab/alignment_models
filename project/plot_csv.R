library(tidyverse)

## This function converts a directory of CSV files containing model selection information into a single tibble for all replicates
## NOTE: Assumes that the following headers are in each CSV: No.,Model,-LnL,df,AIC,AICc,BIC
## NOTE: Assumes each file is named <name>_alnversion_<number>_models.csv
read_all_csv <- function(path_to_csv)
{
    # List of all csv files in the given directory
    files <- dir(path = path_to_csv, pattern = "*.csv")
    tibble(filename = files) %>%
        mutate(file_contents = map(filename,
               ~ read_csv(file.path(path_to_csv, .)))) %>%
        unnest() %>%
        separate(filename, c("name", "dummy", "dummy2")) %>%
        dplyr::select(-dummy, -dummy2, -No., -`-LnL`, -df) %>%
        #separate(filename, c("name", "dummy", "number", "dummy2", "dummy3"), sep="_") %>%
#        dplyr::select(-dummy, -dummy2, -dummy3, -No., -`-LnL`, -df) %>%
        gather(ic_type, ic_value, AIC, AICc, BIC) %>%
        group_by(ic) %>%
        mutate(ic_rank = rank(ic_value)) %>%
        ungroup() -> ranked_models
    ranked_models

}





resdir       <- "dataframes/"
truedir      <- "../simulation/true_simulation_parameters/"
datadir      <- "dataframes/"

# Merge true selection coefficients

files <- dir(path = truedir, pattern = "*selcoeffs.csv")
data_frame(filename = files) %>%
  mutate(file_contents = map(filename,
           ~ read_csv(file.path(truedir, .)))) %>%
  unnest() %>%
  separate(filename, c("dataset", "dummy"), sep="_true_selcoeffs.csv") %>%
  dplyr::select(-dummy) -> true.selcoeffs
write_csv(true.selcoeffs, paste0(resdir, "true_selection_coefficients.csv"))


all.datasets   <- c("1B4T_A", "1RII_A", "1V9S_B", "1G58_B", "1W7W_B", "2BCG_Y", "2CFE_A", "1R6M_A", "2FLI_A", "1GV3_A", "1IBS_A", "HA", "NP", "LAC", "Gal4")
branch.lengths <- c("0.01", "0.5")
dms.datasets   <- c("HA", "NP", "LAC", "Gal4")
methods        <- c("nopenal", "d0.01", "d0.1", "mvn10", "mvn100" , "phylobayes")
