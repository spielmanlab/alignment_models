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

aanewframe <- aa_num_o_mods %>%
  spread(ic_type,number_models)
aanewframe

ntnewframe <- nt_num_o_mods %>%
  spread(ic_type,number_models)
ntnewframe

  
aa_csv <- read_csv(file = "test_aa.csv")
nt_csv <- read_csv(file = "test_nt.csv")

#joining csv withh no spread
aa_combined <- left_join(aa_num_o_mods, aa_csv, by="name")
aa_combined
nt_combined <- left_join(nt_num_o_mods, nt_csv, by="name")

#write_csv(aa_combined,"aanumtest.csv")
#write_csv(nt_combined,"ntnumtest.csv")

#joining csv with csv that has spread info criterion
aa2_com <- left_join(aanewframe,aa_csv,by="name")
nt2_com <- left_join(ntnewframe,nt_csv,by="name")

one_csv <- bind_rows(aa_combined,nt_combined)


write_csv(aa2_com,"aa2numtest.csv")
write_csv(nt2_com,"nt2numtest.csv")

write_csv(one_csv,"one_csv.csv")
          