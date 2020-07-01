# Load Libraries ----------------------
library(tidyverse)

# Define Paths ----------------------

csv_path <- "../results/all_selected_models.csv"

# Read in All Selected Models CSV --------------

csv_dataframe <- read_csv(csv_path)

# Wrangle Header Data -----------------

csv_dataframe %>%
  separate (name,c("name","species","STOP"),sep="[.]") %>%
  dplyr::select(-filename,-STOP) %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model") -> processed_00_models


# Wrangle Further! 
    # Get different versions of processed_models 