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
  ggplot(aes(x = Model, fill = Model)) + geom_bar() + theme_classic() + theme(legend.position = "none") + facet_grid(name~ic_type) 

### Finding Different Examples:

#example from tail(ranked_models), also used during lab meeting
example <- "ENSGT00680000099871.Euteleostomi.009.aa.fas"

head(ranked_models)
tail(ranked_models)

#finding example

e1 <- ranked_models %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(name, number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n) 

tail(e1)
head(e1)
#first result of tail e1, 6 models~
example2 <- "ENSGT00680000099837.Euteleostomi.009.aa.fas"
#really pretty! changed legend name, outlined in black, 6 models, w scale_fill_brewer: PuRd(purple red!)
ranked_models %>%
  filter(name == example2) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() + scale_fill_brewer(palette= "PuRd") + guides(fill=guide_legend(title = "Criterion"))

#first result of head e1, 3 models 
example3 <- "ENSGT00530000062896.Euteleostomi.009.aa.fas"
#first result of head1
ranked_models %>%
  filter(name == example3) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_linedraw() + scale_fill_brewer(palette = "Paired")




### Play with this one. informative legend name: "Criterion". change color scheme get fancy look up function scale_fill_manual OR scale_fill_brewer etc.
### Find a couple representative case for possible outcomes. - one with five models! one with four models! three models! one model.. etc. 
ranked_models %>%
  filter(name == example) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic()

#1 model, boring
example4 = "ENSGT00530000063305.Euteleostomi.009.aa.fas"

ranked_models %>%
  filter(name == example4) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() + scale_fill_brewer(palette= "PuRd") + guides(fill=guide_legend(title = "Criterion"))


### Playground

#legend name:
legend_name <- "Criterion"


# installing wes anderson brewer packages
# Install
install.packages("wesanderson")
# Load
library(wesanderson)

#different colors, using scale_fill_brewer - pastel2, black outline
plot1 <- ranked_models %>%
    filter (name == example) %>%
    ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() + scale_fill_brewer(palette = "Pastel2")
# can't add scale_fill_discrete and scale_fill_brewer in the same code!!!

# wes anderson color :), scale_fill_manual
ranked_models %>%
  filter(name == example) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic() + scale_fill_manual(n = 3, name = "GrandBudapest2")



#with new legend name, black outline
ranked_models %>%
  filter(name == example) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + scale_fill_discrete(legend_name)

#using scale_fill_manual


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
    theme_classic() -> num_models_plot
 #ggsave("output.pdf", num_models_plot) # add args like width = .., height = ..


  
  
  
  
  
  
