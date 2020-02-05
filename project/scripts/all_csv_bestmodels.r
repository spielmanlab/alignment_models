library (tidyverse)
library(plyr)


csv_directory <- "../output_selectome"
#dir() - lists all the files in a directory 
csv_files <- dir(path=csv_directory,pattern="*.csv")
 
ranked %>%
  separate(name,c("name","species","no"),sep="[.]") %>%
  select(-filename,-no)
  
#ranked
