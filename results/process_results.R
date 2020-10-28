# Libraries -----------------------
library(tidyverse)
library(patchwork)
library(cowplot)
theme_set(theme_light() + 
          theme(strip.text = element_text(color = "black")))

# Useful variables,functions -------------------------
total_reps <- 50

percent_best_histogram <- function(df, ic, x, xlabel)
{
  df %>%
    filter(ic_type == ic, 
           {{x}} < 1) %>%
    ggplot(aes(x = {{x}}, fill = dataset)) + 
    geom_histogram(binwidth = 0.1, color = "black") + 
    facet_grid(dataset ~ datatype, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    scale_x_reverse() +
    geom_vline(xintercept = 0.5, color = "grey30") +
    xlab(xlabel) + 
    ggtitle(paste("Model selection by", ic)) +
    theme(legend.position = "none")
}

nmodels_histogram <- function(df, ic, x, xlabel)
{
  df %>%
    filter(ic_type == ic) %>%
    ggplot(aes(x = {{x}}, fill = dataset)) + 
    geom_histogram(binwidth = 1, color = "black") + 
    facet_grid(dataset ~ datatype, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    xlab(xlabel) + 
    ggtitle(paste("Model selection by", ic)) +
    theme(legend.position = "none")
}

reference_matches_common <- function(df, keep, trash, scale_label)
{
  models %>%
    filter(num == 50) %>%
    select(-num, -{{trash}}) %>%
    rename(ref_msa = {{keep}}) -> ref_msa
  
  models %>%
    select(-{{trash}}) %>%
    left_join(ref_msa) %>%
    # we just need one row, doesn't matter which
    filter(num==1) %>%
    mutate(best_is_ref = ref_msa == {{keep}}) %>%
    #   filter(is.na(best_is_ref)) # DONE no NA's :)
    count(dataset, datatype, ic_type, best_is_ref) %>%
    left_join(number_of_datasets) %>%
    mutate(percent = n/total) %>%
    ggplot(aes(x = ic_type, y = percent, fill = best_is_ref)) + 
    geom_col(position = position_dodge(), color = "black", size = 0.25) + 
    geom_text(aes(label = round(percent,2), y = percent + 0.06), position = position_dodge(0.9), size = 3)+
    facet_grid(dataset~datatype, scales = "free") + 
    scale_fill_brewer(palette = "Set1", name = scale_label) + 
    xlab("Information theoretic criterion") + 
    ylab("Percent of alignment groups") +
    theme(legend.position = "bottom",
          panel.grid = element_blank()) 
}



# Load and clean data -----------------------
models_raw <- read_csv("all_selected_models.csv") 
scores_raw <- read_csv("all_alignment_scores.csv")

models_raw %>%
  separate(name, into=c("id", "dataset", "trash"), sep = "\\.") %>%
  replace_na(list(dataset = "PANDIT"))  %>%
  select(-trash, -filename) %>%
  group_by(id, datatype) %>%
  mutate(num = 1:n()) %>% 
  ungroup() %>%
  pivot_longer(AIC:BIC, 
               names_to = "ic_type", 
               values_to = "best_model") %>%
  mutate(best_matrix = str_replace(best_model, "\\+.+", "")) -> models

# TODO: SUM OF THE SCORES ARE NA AND PROBABLY NEED TO BE RERUN??
scores_raw %>%
  rename(id = dataset, 
         dataset = species, 
         #THIS DF HAS EST/REF BACKWARDS !! woops hehe
         est = est_num,
         est_num = ref_num) %>%
  rename(ref_num = est) -> scores

# How many datasets are there? 1000 for each selectome and 236 PANDIT
models %>% 
  filter(ic_type == "AIC", num == 1) %>% 
  count(dataset, datatype, name = "total") -> number_of_datasets



## Analysis: How many models per alignment? How many matrices per alignment? ----------------------------------------
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_models") -> how_many_models


plot_grid(nmodels_histogram(how_many_models, "AIC", n_models, "Number of best-fitting models") , 
          nmodels_histogram(how_many_models, "AICc", n_models, "Number of best-fitting models"), 
          nmodels_histogram(how_many_models, "BIC", n_models, "Number of best-fitting models"), 
          labels = "auto", nrow = 1) -> nmodels_histograms

models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_matrices") -> how_many_matrices



plot_grid(nmodels_histogram(how_many_matrices, "AIC", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "AICc", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "BIC", n_matrices, "Number of best-fitting model matrices"), 
          labels = "auto", nrow = 1) -> nmatrices_histograms



## Analysis: For situations with >1 model, how common is the most common model? For matrices? ----------------------------------------
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  group_by(id, datatype, dataset, ic_type) %>%
  summarize(top_model_percent = max(n)/total_reps) %>%
  ungroup()-> percent_top_models

plot_grid(percent_best_histogram(percent_top_models, "AIC", top_model_percent,"Percentage of reps choosing the most common best-fitting model") , 
          percent_best_histogram(percent_top_models, "AICc", top_model_percent,"Percentage of reps choosing the most common best-fitting model"), 
          percent_best_histogram(percent_top_models, "BIC", top_model_percent,"Percentage of reps choosing the most common best-fitting model"), 
          labels = "auto", nrow = 1) -> percent_best_model_histograms

models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  group_by(id, datatype, dataset, ic_type) %>%
  summarize(top_matrix_percent = max(n)/total_reps) %>%
  ungroup()-> percent_top_matrices

plot_grid(percent_best_histogram(percent_top_matrices, "AIC", top_matrix_percent,"Percentage of reps choosing the most common best-fitting MATRIX") , 
          percent_best_histogram(percent_top_matrices, "AICc", top_matrix_percent,"Percentage of reps choosing the most common best-fitting MATRIX"), 
          percent_best_histogram(percent_top_matrices, "BIC", top_matrix_percent,"Percentage of reps choosing the most common best-fitting MATRIX"), 
          labels = "auto", nrow = 1) -> percent_best_matrix_histograms


save_plot("percent_best_model_histograms.png", percent_best_model_histograms, base_width = 14)
save_plot("percent_best_matrix_histograms.png", percent_best_matrix_histograms, base_width = 14)



# Analysis: Among IC, do we see same or different number of models? -------------------------------

# todo: matrices?


how_many_models %>%
  mutate(number_models = case_when(n_models <= 4 ~ n_models, 
                                   n_models >= 4 ~ as.integer(5))) %>%
  select(-n_models) %>%
  pivot_wider(names_from = "ic_type", values_from = "number_models") -> how_many_models_wide_ic

how_many_models_wide_ic %>%
  select(-BIC) %>%
  count(datatype, dataset, AIC, AICc, name = "combo_percent") %>%
  left_join(number_of_datasets) %>%
  mutate(combo_percent = combo_percent / total) %>%
  select(-total) %>%
  ggplot(aes(x = AIC, y = AICc, fill = combo_percent)) + 
    geom_point(pch = 22, color ="black", size=15) +
    geom_text(aes(label = round(combo_percent,3),
                  color = combo_percent <= 0.15), # neat trick! scale_color_manual has it
              size = 3) + 
    facet_wrap(datatype ~ dataset) +
  scale_fill_distiller(palette = "YlGnBu", 
                       name = str_wrap("Percentage of datasets", 30))  +
  scale_color_manual(values = c("black", "grey90")) +
  xlab("Unique number of models by AIC") + 
  ylab("Unique number of models by AICc") + 
  theme(legend.position = "bottom") + 
  guides(color = FALSE) +
  scale_x_continuous(expand=c(0.1,0.1),
                     breaks = 1:5, 
                     labels=c("1", "2", "3", "4", "5+")) + 
  scale_y_continuous(expand=c(0.1,0.1),
                     breaks = 1:5, 
                     labels=c("1", "2", "3", "4", "5+")) 
  

## Analysis: How many times was the "top model" also the reference alignment model? Matrix? ---------
# THIS IS A CRUX FIGURE!!!
# This figure shows: for AA, roughly 80-90% of the time we are consistent with a reference. For NT, we are 75-80% consistent with reference. There is therefore substantial potential that the best-fitting model selected by any criterion would change if the alignment were different. 
# For matrix, we are about half of that, but more consistency for AA than for NT. 

reference_matches_common(models, 
                         best_model, 
                         best_matrix, 
                         "Most common matrix matches reference MSA model") -> ref_match_model_plot

reference_matches_common(models, 
                         best_matrix, 
                         best_model, 
                         "Most common model matches reference MSA model") -> ref_match_matrix_plot
plot_grid(ref_match_model_plot, ref_match_matrix_plot, nrow=1, labels = "auto", scale = 0.95) -> ref_plot
save_plot("reference_model_matches.png", ref_plot, base_width = 12, base_height = 5)
  



# Analysis: For alignment groups with 1 model, how do the SP/TC scores compare?

how_many_models %>%
  mutate(number_models = case_when(n_models == 1 ~ "1", 
                                   n_models == 2 ~ "2", 
                                   n_models == 3 ~ "3", 
                                   n_models == 4 ~ "4", 
                                   n_models >= 5 ~ "5+")) %>%
  select(-n_models) -> how_many_models_categories


# Scores where all the models are the SAME
how_many_models %>% 
  filter(n_models == 1) %>%
  inner_join(scores) %>%
  group_by(id, dataset, datatype, ic_type) %>%
  summarize(sp = mean(sp, na.rm=T), 
            tc = mean(tc, na.rm=T)) %>%
  pivot_longer(sp:tc, names_to = "score_type", values_to = "mean_score") %>%
  ggplot(aes(x = score_type, y = mean_score, fill = datatype)) + 
    geom_boxplot(color = "black", outlier.size = 0.3) +
    facet_grid(dataset~ic_type)

# Scores where same as rep50 vs different from rep50 (don't care what other model)
models %>%
  filter(num == 50) %>%
  select(-num) %>%
  rename(rep50_model = best_model) %>%
  left_join(models) %>%
  mutate(same_as_rep50 = rep50_model == best_model) %>%
  filter(num != 50) %>%
  select(-rep50_model, -best_model) %>%
  rename(est_num = num) %>%
  # don't consider where all are true since that's 1 model
  group_by(id, dataset, datatype, ic_type) %>%
  mutate(total_same = sum(same_as_rep50)) %>%
  ungroup() %>%
  filter(total_same < (total_reps-1)) %>%
  select(-total_same) -> models_vs_rep50

models_vs_rep50 %>%
  left_join(scores %>% select(-ref_num)) %>%
  rename(rep_num = est_num) %>%
  distinct() %>%
  group_by(id, dataset, datatype, ic_type, same_as_rep50) %>%
  summarize(SP = mean(sp, na.rm=T), 
            TC = mean(tc, na.rm=T)) %>%
  pivot_longer(SP:TC, names_to = "score_type", values_to = "mean_score") %>%
  mutate(same_as_rep50_char = if_else(same_as_rep50, "Same as reference MSA model", "Different from reference MSA model")) %>%
  ggplot(aes(x = score_type, y = mean_score, fill = fct_relevel(same_as_rep50_char, "Same as reference MSA model"))) + 
    geom_boxplot(color = "black", outlier.size = 0.3) +
    facet_grid(ic_type~dataset) + 
    scale_fill_brewer(palette = "Set2", name = "Selected model") + 
    xlab("MSA score measurement") + 
    ylab("MSA scores")
    
  


# Plot: scatterplot of percent model vs percent matrix. Not sure that this communicates well.

percent_top_matrices %>% 
  left_join(percent_top_models) %>% 
  filter(ic_type == "AIC") %>%
  ggplot(aes(x = top_model_percent, y = top_matrix_percent, color = dataset)) + 
  geom_point(alpha = 0.5) + 
  facet_grid(datatype~dataset) + 
  xlim(0.1, 1) + ylim(0.1,1) + 
  scale_color_brewer(palette = "Set1")
# top vertical line: a bunch of models, same matrix
# diagonal line: top model is a distinct matrix
# 

