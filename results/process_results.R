# Libraries -----------------------
library(tidyverse)
library(patchwork)
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
    geom_vline(xintercept = 0.5, color = "grey40") +
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


# Analysis: How many models per alignment?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_models") -> how_many_models


plot_grid(nmodels_histogram(how_many_models, "AIC", n_models, "Number of best-fitting models") , 
          nmodels_histogram(how_many_models, "AICc", n_models, "Number of best-fitting models"), 
          nmodels_histogram(how_many_models, "BIC", n_models, "Number of best-fitting models"), 
          labels = "auto", nrow = 1) -> nmodels_histograms

# Analysis: How many MATRICES per alignment?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_matrices") -> how_many_matrices

# todo has bad labeling since function
plot_grid(nmodels_histogram(how_many_matrices, "AIC", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "AICc", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "BIC", n_matrices, "Number of best-fitting model matrices"), 
          labels = "auto", nrow = 1) -> nmatrices_histograms



# Analysis: For situations with >1 model, how common is the most common model?
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


# Analysis: For situations with >1 MATRICES, how common is the most common MATRIX?
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


# Analysis: Among IC, do we see same or different number of models?


# How many datasets are there? 1000 for each selectome and 236 PANDIT
models %>% 
  filter(ic_type == "AIC", num == 1) %>% 
  count(dataset, datatype, name = "total") -> number_of_datasets

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
  

# Analysis: Among IC, are model "deviations" from ref the same or different alignment replicates?






# Analysis: For situations 1 model, how do the scores compare?

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
    
  
