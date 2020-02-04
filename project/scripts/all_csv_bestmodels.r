library (tidyverse)
library(plyr)

csv_directory <- "../output_selectome"
all_csv_files <- list.files(path=csv_directory,pattern="*.csv",full.names = TRUE)
#all_csv_files

#ldlpy - For each element of a list, apply function then combine results into a data frame.
data_all_csv <- ldply(all_csv_files,read_csv)
data_all_csv
