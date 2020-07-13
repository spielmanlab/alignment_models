# Load Libraries ----------------------
library(tidyverse)

# Define Paths and Constants ----------------------

csv_path <- "../results/all_selected_models.csv"

flies = "Drosophila"
vert = "Euteleostomi"
amino = "AA"
nuc = "NT"


# Read in All Selected Models CSV --------------

csv_dataframe <- read_csv(csv_path)

# Wrangle Header Data ------------------------

csv_dataframe %>%
  separate (name,c("name","species","STOP"),sep="[.]") %>%
  dplyr::select(-filename,-STOP) %>%
  pivot_longer(AIC:BIC, names_to = "ic_type", values_to = "model")-> processed_00_models

# How Many Models Per Dataset?--------------------------------

process_ready_data <- function(dataset,a_species,a_datatype)
{
  dataset %>%
    filter(species==a_species,datatype==a_datatype)%>%
    group_by(name,model,ic_type,datatype) %>%
    tally() %>%
    ungroup() %>%
    select(-n) %>%
    group_by(name,ic_type) %>%
    tally() %>% 
    rename(number_datasets = n ) %>%
    group_by(number_datasets, ic_type) %>% 
    tally() %>% 
    rename(number_of_models = n) -> ready_data
  ready_data
  
}  

processed_dros_data_aa <- process_ready_data(processed_00_models,flies,nuc)

# Plot How Many Models Per Dataset ----------------------

plot_processed_alignments <- function(ready_data)
{
  
  ready_data %>%
    ggplot(aes(x=number_datasets,y=number_of_models,width=.86)) +
    geom_col() + 
    geom_text(aes(x = number_datasets, y = number_of_models + 1, label = number_of_models),size=3,hjust=.5,vjust=.01)+
    facet_wrap(~ic_type) + 
    xlab("Number of Datasets") +
    ylab("Number of Selected Models") +
    theme_linedraw()  +
    scale_x_continuous(breaks=seq(0,20,1))+
    theme(plot.title=element_text(hjust=0.5))-> plotted_data
  plotted_data
  
}

plotted_dros_aa_data <- plot_processed_alignments(processed_dros_data_aa)
