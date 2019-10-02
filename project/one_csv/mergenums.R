library(plyr)
library(tidyverse)


aa_csv <- read_csv(file ="aa_data_properties.csv")
nt_csv <- read_csv(file ="nt_data_properties.csv")

process_percent_csv <- function(path_to_csv)
{
files <-dir(path = path_to_csv, pattern = "*.csv")
tibble(filename = files) %>%
  mutate(file_contents = map(filename,
                             ~ read_csv(file.path(path_to_csv, .)))) 
}

aa_mypath = "../selectome_aa_output/"
#aa_myfiles <- list.files(path=aa_mypath, pattern="*.csv", full.names = TRUE)
#aa_dat_csv <- ldply(aa_myfiles,read_csv)
nt_mypath = ("../selectome_nt_output/")
#nt_myfiles <- list.files(path=nt_mypath, pattern = "*.csv", full.names = TRUE)
#nt_dat_csv <- ldply(nt_myfiles,read_csv)

aa_percent <- process_percent_csv(aa_mypath)
nt_percent <- process_percent_csv(nt_mypath)

### creating a percent rank of ic_value column in aa_tibble
aa_percent %>%
  unnest() %>%
  separate(filename, c("name", "dummy", "number", "dummy2"), sep="_") %>%
  dplyr::select(-dummy, -dummy2, -No., -`-LnL`, -df) %>%
  gather(ic_type, ic_value, AIC, AICc, BIC) %>%
  group_by(name, number, ic_type) %>%
  mutate(percent_rank = percent_rank(ic_value)) %>%
  dplyr::select(name, number, Model, ic_type, percent_rank)
### creating a percent rank of ic_value column in nt_tibble
nt_percent %>%
  unnest() %>%
  separate(filename, c("name", "dummy", "number", "dummy2"), sep="_") %>%
  dplyr::select(-dummy, -dummy2, -No., -`-LnL`, -df) %>%
  gather(ic_type, ic_value, AIC, AICc, BIC) %>%
  group_by(name, number, ic_type) %>%
  mutate(percent_rank = percent_rank(ic_value)) %>%
  dplyr::select(name, number, Model, ic_type, percent_rank)


#################################################################
#getting aa_ranked_models
aa_ranked <- read_csv(file = "../aa_ranked_models.csv")
aa_ranked$name <- gsub(".aa.fas","", aa_ranked$name)

#getting nt_ranked_models
nt_ranked <- read_csv(file = "../nt_ranked_models.csv")
nt_ranked$name <- gsub(".fas", "",nt_ranked$name)

#merging aa_ranked_models with aa_csv 
aa_fullcsv <- merge(aa_csv, aa_ranked, by = "name")
aa_fullcsv
#merging nt_ranked_models with nt_csv
nt_fullcsv <- merge(nt_csv, nt_ranked, by = "name")
nt_fullcsv
################################################################

#PLOTS!
### AA Full CSV (ranked and csv)
##Min seq against model
aa_fullcsv %>%
  ggplot(aes(x = Model, fill = min)) + geom_bar(position = position_dodge(), fill = "navy") +
  xlab("Model") + ylab("Minimum Number of Sequences in File") +
  theme(axis.text.x = element_text(lineheight = 1, hjust = 1, size= 3))

#max violin plot
aa_fullcsv %>%
  ggplot(aes(x = max, y = max)) + geom_violin(col = "blue", fill = "red") 

#ic_type over model
aa_fullcsv %>%
  ggplot(aes(x = Model, y = ic_type)) + geom_count(col = "violet") + 
  ylab("Information Criterion") + xlab ("Model") +
  theme(plot.title = element_text(hjust = 10),
  axis.text.x = element_text(size = 3, hjust = .001), axis.title.y = element_text(size = 14))

#max over min - rug and point
aa_fullcsv %>%
  ggplot(aes(x = min, y = max)) + geom_point() + geom_rug(col = "deeppink3")

### NT Full CSV (ranked and csv)
#number of sequences over filename (big plot)
nt_fullcsv %>%
  ggplot(aes(y = number_of_sequences, x = name)) + geom_col() +
  scale_fill_brewer(palette = "Spectral") + xlab("Name of File") +
  ylab("Number of Sequences") +
  theme_minimal()

#standev over mean 
nt_fullcsv %>% 
  ggplot(aes(x = mean, y = standev)) + geom_jitter(col = "darkred") +
  xlab("Mean of NT Sequences") + ylab("Standard Deviation of NT Sequences")

#max vs min
nt_fullcsv %>%
  ggplot(aes(x = min, y = max)) + geom_rug(col = "darkgoldenrod3") +
  xlab("Mininum Number of Sequences in Each File") +
  ylab("Maximum Number of Sequences in Each File") + theme_light()



                                           