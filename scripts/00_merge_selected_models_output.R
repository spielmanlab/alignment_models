# Load Libraries ------------------------
library(tidyverse)

## Add structure with "# stuff -----" comments
###### 1) load libraries
###### 2) define paths, names of files to be read in or out
###### 3) any functions if you have them
###### 4) analyze as many #stuff-- as needed

## In the end, this script should (or change it an Rmd!!)
# read in the "../results/selected_models_output/" files and merge to 1 csv. SAVE IT for future use.
# then, make tibbles ala csv_tidydata_progress. Specifically:
#### 1) number of models per dataset
#### 2) we will want to know whether each alignment's model == / != #50's model

# Define Paths --------------------------
csv_directory <- "../results/selected_models_output/"
csv_path <-"../results/all_selected_models_.csv"
#dir() - lists all the files in a directory 
csv_files <- dir(path=csv_directory,pattern="*.csv")

# Create CSV ----------------------------

afile_tibble <- tibble(filename=csv_files) 
csvdf <- afile_tibble %>%
  mutate(file_contents=map(filename,
                           ~ read_csv(file.path(csv_directory, .)))) %>%
  unnest() 

# at this point looks like:
#filename,name,datatype,AIC,AICc,BIC
#EMGT00050000000002.Drosophila.001_AA_bestmodels.csv,EMGT00050000000002.Drosophila.001,AA,Dayhoff+F+I+G4,Dayhoff+F+I+G4,Dayhoff+F+G4

# we want:
#name,datatype,species,AIC,AICc,BIC
#EMGT00050000000002,AA,Drosophila,Dayhoff+F+I+G4,Dayhoff+F+I+G4,Dayhoff+F+G4
write_csv(csvdf,path=csv_path)

# Read in Newly Created CSV ---------------------

csv_dataframe <- read_csv(csv_path)

# Wrangle Header Data -------------------

csv_dataframe %>%
  separate(name,c("name","species","STOP"),sep="[.]")



