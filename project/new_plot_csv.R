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
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n) %>%
  ggplot(aes(x = number_models, y = name)) + 
  geom_col(color = "black") + 
  geom_text(aes(x = number_models, y = name + 1, label = name)) +
  facet_wrap(~ic_type) + 
  theme_classic() + scale_x_continuous(name = "Number of Models per Dataset") +
  scale_y_continuous(name = "Number of Datasets")

#-> num_aa_models_plot


nt_ranked_models %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n) %>%
  ggplot(aes(x = number_models, y = name)) + 
  geom_col(color = "black") + 
  geom_text(aes(x = number_models, y = name + 1, label = name))+
  facet_wrap(~ic_type) + 
  theme_classic()  + scale_y_continuous(expand=c(0,0), name = "Number of Datasets", limits = c(0, 125)) +
  scale_x_continuous(name = "Number of Modles per Dataset") 

# -> num_nt_models_plot

ggsave("num_nt_plot.pdf", num_nt_models_plot) # add args like width = .., height = ..

# i = 0
# for (plot1 in c(num_nt_models_plot, num_aa_models_plot)) {
#   ggsave(str(i) + "output.pdf", plot1)
#          i = i + 1
# }
# i = 0
# for (plot1 in c(num_nt_models_plot, num_aa_models_plot)) {
#   ggsave(paste0(i, "output.pdf"), plot1)
#          i = i + 1
# }
# 
# 
# ggsave("output.pdf", num_nt_models_plot) # add args like width = .., height = ..
# 


