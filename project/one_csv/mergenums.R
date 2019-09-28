library(tidyverse)

aa_csv <- read.csv(file ="one_csv/aa_data_properties.csv")
nt_csv <- read.csv(file ="one_csv/nt_data_properties.csv")

head(aa_csv)

aa_csv %>%
  ggplot(aes(x = min, fill = min)) + geom_bar(position = position_dodge()) + theme_classic()

aa_csv %>%
  ggplot(aes(x = max, y = min)) + geom_point()

aa_csv %>% 
    ggplot(aes(min, max)) + geom_violin() + geom_jitter()
