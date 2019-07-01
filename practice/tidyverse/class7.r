library(tidyverse)
theme_set(theme_bw(base_size=12)) #default ggplot2 theme
install.packages("nycflights13")
library(nycflights13)

#tidyverse and nycflights13
#1. joining tables

population <- read.csv(text=
                         "city,year,population
                       Houston,2014,2239558
                       San Antonio,2014,1436697
                       Austin,2014,912791
                       Austin,2010,790390", stringsAsFactors = FALSE)
population

area <- read.csv(text=
                   "city,area
                 Houston,607.5
                 Dallas,385.6
                 Austin,307.2", stringsAsFactors = FALSE)
area

#a. combine these two tables using left.right join and inner
#joined by city:
left_join(population, area)

inner_join(population, area)

right_join(population, area)

left_join(area, population)





