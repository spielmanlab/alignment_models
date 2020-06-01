library(tidyverse)

csv_directory <- "../results/selected_models_output/"
#dir() - lists all the files in a directory 
csv_files <- dir(path=csv_directory,pattern="*.csv")
afile_tibble <- tibble(filename=csv_files) 
csvdf <- afile_tibble %>%
  mutate(file_contents=map(filename,
                           ~ read_csv(file.path(csv_directory, .)))) %>%
  unnest() 

write_csv(csvdf,path="../results/all_selected_models.csv")



