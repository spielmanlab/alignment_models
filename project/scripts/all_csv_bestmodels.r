library (tidyverse)
library(plyr)


csv_directory <- "../output_selectome"
#dir() - lists all the files in a directory 
csv_files <- dir(path=csv_directory,pattern="*.csv")
file_tibble <- tibble(filename=csv_files) 
ranked <- file_tibble %>%
  mutate(file_contents=map(filename,
                            ~ read_csv(file.path(csv_directory, .)))) %>%
  unnest() 
ranked %>%
  separate(name,c("name","species","no"),sep="[.]") %>%
  select(-filename,-no)
  
#ranked
