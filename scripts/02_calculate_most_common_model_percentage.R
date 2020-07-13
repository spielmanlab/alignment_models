# Load Libraries ----------------------
library(tidyverse)

# Define Paths and Constants ----------------------

csv_path <- "../results/all_selected_models.csv"

# Read in All Selected Models CSV --------------

csv_dataframe <- read_csv(csv_path)

# Wrangle Header Data ------------------------

csv_dataframe %>%
  separate (name,c("name","species","STOP"),sep="[.]") %>%
  dplyr::select(-filename,-STOP) %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model")-> processed_00_models

# What is the top percentage of the most common model? --------------
processed_00_models %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model") %>%
  group_by(name,species,datatype,ic_type) %>%
  # add column `total` that is total number of alignments per dataset (it's 50)
  mutate(total = n() )%>%
  ungroup() %>%
  group_by(name,species,datatype,ic_type, model) %>%
  # Number of times a given model occurred in the alignments for a dataset, per IC
  mutate(n = n()) %>%
  # Convert number of occurrences to a percentage of total, per dataset per IC
  mutate(percent_each_model = n/total) %>%
  ungroup() -> percent_selected_models 

# What is the most common model? 

percent_selected_models %>%
  # group data together only by what we're interested in
  group_by(ic_type,model) %>%
  # create new column that contains the max percent seen in both ic_type and model
  mutate(max_percent = max(percent_each_model)) %>%
  ungroup() %>%
  group_by(name,datatype,ic_type,model)

