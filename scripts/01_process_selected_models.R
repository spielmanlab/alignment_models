# Load Libraries ----------------------
library(tidyverse)

# Define Paths ----------------------

csv_path <- "../results/all_selected_models.csv"

# Read in All Selected Models CSV --------------

csv_dataframe <- read_csv(csv_path)

# Wrangle Header Data -----------------

csv_dataframe %>%
  separate (name,c("name","species","STOP"),sep="[.]") %>%
  dplyr::select(-filename,-STOP) -> processed_00_models

# Wrangle Percent Top Model  --------------------------

processed_00_models %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model") %>%
  group_by(name,species,datatype,ic_type) %>%
  mutate(total = n()) %>%
  ungroup() %>% 
  group_by (name,species,datatype,ic_type,model) %>%
  mutate(number_of_models = n()) %>%
  ungroup -> dummy_var
# After creating above variable, I can mutate a new column that contains
#model percentage, but I'm not sure if that is the top model percentage


# Playing around with data ----------------------------

processed_00_models %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model") %>%
  group_by(name,species,datatype,ic_type,model) %>%
  tally() %>%
  ungroup()

processed_00_models %>%
  group_by(name,species,datatype,AIC,AICc,BIC) %>%
  mutate(total = n())
  tally() %>% 
  ungroup()
  
  
