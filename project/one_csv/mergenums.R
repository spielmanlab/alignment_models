library(plyr)
library(tidyverse)
library(readr)


aa_csv <- read.csv(file ="aa_data_properties.csv")
nt_csv <- read.csv(file ="nt_data_properties.csv")

aa_mypath = "../selectome_aa_output/"
aa_myfiles <- list.files(path=aa_mypath, pattern="*.csv", full.names = TRUE)
aa_dat_csv <- ldply(aa_myfiles,read_csv)
aa_dat_csv
nt_mypath = ("../selectome_nt_output/")
nt_myfiles <- list.files(path=nt_mypath, pattern = "*.csv", full.names = TRUE)
nt_dat_csv <- ldply(nt_myfiles,read_csv)

aa_ranked <- read.csv(file = "../aa_ranked_models.csv")
aa_ranked$name <- gsub(".aa.fas","", aa_ranked$name)
aa_ranked

nt_ranked <- read.csv(file = "../nt_ranked_models.csv")
nt_ranked$name <- gsub(".fas", "",nt_ranked$name)
nt_ranked

aa_fullcsv <- merge(aa_csv, aa_ranked, by = "name")
aa_fullcsv

nt_fullcsv <- merge(nt_csv, nt_ranked, by = "name")
nt_fullcsv

##Min count plot
aa_fullcsv %>%
  ggplot(aes(x = min, fill = min)) + geom_bar(position = position_dodge()) + theme_classic()

#max violin plot
aa_fullcsv %>%
  ggplot(aes(x = max, y = max)) + geom_violin()

aa_fullcsv %>%
  ggplot(aes(x = ))

