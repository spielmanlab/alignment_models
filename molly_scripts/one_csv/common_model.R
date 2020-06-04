library(tidyverse)


#what i'm doing again: if 
total_per <- 50 
aa_ranked <- read_csv("../aa_ranked_models.csv")
nt_ranked <- read_csv("../nt_ranked_models.csv")

aa_num_by_ic <-aa_ranked %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>%
  ungroup() %>% 
  rename(number_of_models = n) %>% 
  drop_na() %>%
  group_by(name,Model) %>%
  mutate(per=total_per) %>%
  mutate(percent=number_of_models/per) %>%
  select(-per) %>%
  ungroup() 
#count dplyr
  

aanum <- aa_ranked %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>%
  ungroup() %>% 
  rename(number_of_models = n) 
  
aa_ranked %>% count(name, ic_type) %>% rename(total=n) %>%left_join(aa_ranked) %>%
  select(-number) %>%
  count(name,Model,ic_type)
  
  
nt_num_by_ic <- nt_ranked %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>%
  ungroup() %>% 
  rename(number_of_models = n) %>% 
  drop_na() %>%
  group_by(name,Model) %>%
  mutate(per=total_per) %>%
  mutate(percent=number_of_models/per) %>%
  select(-per) %>%
  ungroup() 
