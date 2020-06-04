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

my_path <- "selectome_aa_subset_output/"
ranked_models <- process_all_csv(my_path)



# ranked_models %>%
#   filter(name == example) %>%
#   ggplot(aes(x = Model, fill = Model)) + geom_bar() + theme_classic() + theme(legend.position = "none") + facet_wrap(~ic_type)

### baaaad
ranked_models %>%
  ggplot(aes(x = Model, fill = Model)) + geom_bar() + theme_classic() + theme(legend.position = "none") + facet_grid(name~ic_type) + panel_border()


example <- "ENSGT00680000099871.Euteleostomi.009.aa.fas"
### Play with this one. informative legend name: "Criterion". change color scheme get fancy look up function scale_fill_manual OR scale_fill_brewer etc.
### Find a couple representative case for possible outcomes. - one with five models! one with four models! three models! one model.. etc. 
ranked_models %>%
  filter(name == example) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic()

ranked_models %>% group_by(name, Model, ic_type) %>% tally()




ranked_models %>% 
  filter(ic_type == "BIC") -> ranked_models_bic

## Wrangles data and then makes plot where x = number of models and y = number of datasets, faceted by IC.
### This shows us how many models are selected for each datasets where a dataset=50 alignment versions
### colors!!!
ranked_models %>%
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
    geom_col() + 
    geom_text(aes(x = number_models, y = name + 1, label = name))+
    facet_wrap(~ic_type) + 
    theme_classic() + panel_border() -> num_models_plot
#ggsave("output.pdf", num_models_plot) # add args like width = .., height = ..


  
  
  
  
  
  
