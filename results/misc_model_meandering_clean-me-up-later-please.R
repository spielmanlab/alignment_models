# Libraries -----------------------
library(tidyverse)
library(cowplot)
library(ggtext)
theme_set(theme_light() + 
          theme(strip.text = element_text(color = "black")))
source("utils.R")
# Useful variables,functions -------------------------
total_reps <- 50
output_path <- "figures/"
# Load and clean data -----------------------
models <- read_csv("all_selected_models.csv") %>% process_raw_models() # note: this has a warning and it's fine
scores <- read_csv("all_alignment_scores.csv")
hamming <- read_csv("pairwise_hamming_distances.csv")
setwd("results/")
# Libraries -----------------------
library(tidyverse)
library(cowplot)
library(ggtext)
theme_set(theme_light() + 
          theme(strip.text = element_text(color = "black")))
source("utils.R")
# Useful variables,functions -------------------------
total_reps <- 50
output_path <- "figures/"
# Load and clean data -----------------------
models <- read_csv("all_selected_models.csv") %>% process_raw_models() # note: this has a warning and it's fine
scores <- read_csv("all_alignment_scores.csv")
hamming <- read_csv("pairwise_hamming_distances.csv")
models %>% 
  filter(ic_type == "AIC", num == 1) %>% 
  count(dataset, datatype, name = "total") -> number_of_datasets
# How many models per dataset?  
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_models") -> how_many_models
hamming
how_many_models 
hamming <- read_csv("pairwise_hamming_distances.csv") %>% rename(id = dataname)
how_many_models %>% full_join(hamming)
nrow(how_many_models
)
nrow(hamming)
how_many_models %>% full_join(hamming) %>% filter(datatype == "AA", ic_type == "AIC")
how_many_models %>% full_join(hamming) %>% filter(datatype == "AA", ic_type == "AIC")
data_info <- read_csv("nsites_nseqs.csv")
data_info
data_info <- read_csv("nsites_nseqs.csv") %>% rename(id = name)
how_many_models %>% full_join(hamming) %>% full_join(data_info) %>% filter(datatype == "AA", ic_type == "AIC")
how_many_models %>% full_join(hamming) %>% full_join(data_info) %>% filter(datatype == "AA", ic_type == "AIC") %>% drop_na()
how_many_models %>% full_join(hamming) %>% full_join(data_info) %>% filter(datatype == "AA", ic_type == "AIC") -> df
summary(lm(n_models ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = df))
df %>% mutate(stable = ifelse(n_models == 1, 1,0)) -> df2
library(pROC)
lgfit <- glm(stable ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = df2, family = "binomial")
roc(lgfit$fitted.values, df2$stable)
roc(df2$stable, lgfit$linear.predictors)
summary(lgfit)
summary(lm(n_models ~ median_hamming + sd_hamming + nseq + mean_nsites, data = df))
lgfit <- glm(stable ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = df2, family = "binomial")
summary(lm(n_models ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = df))
lgfit <- glm(stable ~ median_hamming + sd_hamming + nseq + mean_nsites, data = df2, family = "binomial")
lgfitmean <- glm(stable ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = df2, family = "binomial")
roc(df2$stable, lgfit$linear.predictors)
roc(df2$stable, lgfitmean$linear.predictors)
lgfit
summary(lgfit)
how_many_models %>% full_join(hamming) %>% full_join(data_info) %>% filter(datatype == "NT", ic_type == "AIC") -> dfnt
summary(lm(n_models ~ mean_hamming + sd_hamming + nseq + mean_nsites, data = dfnt))
dfnt %>% mutate(stable = ifelse(n_models == 1, 1,0)) -> dfnt2
lgfit <- glm(stable ~ median_hamming + sd_hamming + nseq + mean_nsites, data = dfnt2, family = "binomial")
roc(df2$stable, lgfit$linear.predictors)
