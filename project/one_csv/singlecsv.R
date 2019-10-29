library(plyr)
library(tidyverse)
library(magrittr)


aa_dataproperties <- read_csv(file = "test_aa.csv")
#head(aa_dataproperties)
nt_dataproperties <- read_csv(file ="test_nt.csv")
head(nt_dataproperties)

#getting aa_ranked_models
aa_ranked <- read_csv(file = "../aa_ranked_models.csv")
aa_ranked$name <- gsub(".aa.fas","", aa_ranked$name)

#getting nt_ranked_models
nt_ranked <- read_csv(file = "../nt_ranked_models.csv")
nt_ranked$name <- gsub(".fas", "",nt_ranked$name)

# getting aa number of models based on ic_type 
aa_num_o_mods <-aa_ranked %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(name, number_models, ic_type)
#getting nt number of models based on ic_type
nt_num_o_mods <-nt_ranked %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(name, number_models, ic_type) 


