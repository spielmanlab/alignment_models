# Libraries -----------------------
library(tidyverse)
library(magrittr) # %<>%
library(modelr)
library(cowplot)
library(ggtext)
library(ungeviz) # wilkelab/unggeviz
library(pROC)

theme_set(theme_light() + 
          theme(strip.text = element_text(color = "black"),
                legend.position = "bottom"
               )
          )


# Useful variables,functions ---------------------------------------------------
total_reps <- 50
output_path <- "figures/"

# Load and clean data ----------------------------------------------------------
source("load_prepare_data.R")

# Build and visualize the GLMs -------------------------------------------------
source("build_plot_glms.R") 


# Barplot of model stability counts --------------------------------------------
how_many_models %>%
  mutate(stability = ifelse(n_models == 1, "Stable", "Unstable")) %>%
  group_by(datatype, dataset, ic_type) %>%
  count(stability) %>%
  full_join(number_of_datasets) %>%
  mutate(n = round(n/total, 2)) %>%
  ggplot(aes(x = stability, fill = ic_type, y = n)) + 
    geom_col(position = position_dodge(), color = "black", size = 0.3) + 
    geom_text(aes(label = n, y = n+.05), position = position_dodge(width = 1), size=2.5) +
    facet_grid(datatype ~ dataset) + 
    scale_fill_brewer(name = "", palette = "Dark2") +
    labs(x = "Dataset stability", y = "Percent of datasets") + 
    scale_y_continuous(limits=c(0,1)) +
    theme(legend.position = "bottom", 
          panel.grid.minor.y = element_blank()) -> stability_bar
ggsave(file.path(output_path, "stability_bar.pdf"), stability_bar, width = 8, height = 4)


# Barplot of matrix stability for n_models >1 with AIC -------------------------
full_join(how_many_models, how_many_matrices) %>%
  filter(n_models > 1, ic_type == "AIC") %>%
  mutate(qstability = ifelse(n_matrices == 1, "Same Q matrix", "Different Q matrices")) %>%
  # have to count for a geom_text
  count(dataset, datatype, qstability) %>%
  group_by(dataset, datatype) %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  mutate(p = round(n/total, 2)) %>%
  mutate(fudge = ifelse(datatype == "NT", p+0.04, p+0.03)) %>%
  ggplot(aes(x = dataset, y = p, fill = qstability)) + 
  geom_col(color = "black", size = 0.3, position = position_dodge()) + 
  geom_text(aes(label = p, y = fudge), size = 2.5, position = position_dodge(width = 1))+
  facet_wrap(vars(datatype), scales = "free_y") + 
  scale_fill_brewer(palette = "Dark2", name = "") +
  xlab("Dataset source") +
  ylab("Percent of unstable datasets") + 
  theme(legend.position = "bottom",
        panel.grid.minor.y = element_blank()) -> qstability
ggsave(file.path(output_path, "qstability.pdf"), qstability, width = 8, height = 3)

# Barplot of matrix stability for n_models >1 with AICc and BIC for SI ---------
full_join(how_many_models, how_many_matrices) %>%
  filter(n_models > 1, ic_type != "AIC") %>%
  mutate(qstability = ifelse(n_matrices == 1, "Same Q matrix", "Different Q matrices")) %>%
  # have to count for a geom_text
  count(dataset, datatype, qstability, ic_type) %>%
  group_by(dataset, datatype, ic_type) %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  mutate(p = round(n/total, 2)) %>%
  ggplot(aes(x = dataset, y = p, fill = qstability)) + 
  geom_col(color = "black", size = 0.3, position = position_dodge()) + 
  geom_text(aes(label = p, y = p+0.055), size = 2.5, position = position_dodge(width = 1))+
  facet_grid(ic_type ~ datatype) + 
  scale_fill_brewer(palette = "Dark2", name = "") +
  xlab("Dataset source") +
  ylab("Number of datasets") + 
  theme(legend.position = "bottom") -> si_qstability
ggsave(file.path(output_path, "si_qstability.pdf"), si_qstability, width = 8, height = 4)

# Histograms: how many models and percentage top model -------------------------
how_many_models %>%
  filter(n_models >1, ic_type == "AIC") %>%
  mutate(n_models = ifelse(n_models <=5, n_models, ">5")) %>%
  mutate(n_models = factor(n_models, levels=c(1:5, ">5"))) %>%
  # have to count for a geom_text
  count(dataset, datatype, n_models) %>%
  ggplot(aes(x = n_models, y = n, fill = dataset)) + 
  geom_col(color = "black", size = 0.3) + 
  geom_text(aes(label = n, y = n+15), size = 2.5)+
  facet_grid(datatype ~ dataset, scales = "free") + 
  scale_fill_brewer(palette = "Set1") +
  xlab("Unique selected models per dataset") +
  ylab("Number of datasets") + 
  theme(legend.position = "none") -> howmanymodels_aic_bar

percent_top_models %>%
  filter(top_model_percent < 1, ic_type == "AIC") %>%
  ggplot(aes(x = top_model_percent, fill = dataset)) + 
  geom_histogram(bins = 20, color = "black", size = 0.3) +
  facet_grid(datatype~dataset, scales = "free") + 
  scale_fill_brewer(palette = "Set1") +
  scale_x_reverse(breaks=rev(seq(0, 1, 0.2))) +
  theme() +
  xlab("Percentage of MSA variants selecting the M<sup>0</sup> model")+
  ylab("Number of datasets") +
  theme(legend.position = "none", 
        axis.title.x = element_textbox()) -> percentage_m0_model


plot_grid(howmanymodels_aic_bar, 
          percentage_m0_model,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0
ggsave(file.path(output_path, "nmodels_percentm0.pdf"), 
       nmodels_percentm0, width = 12, height = 4)


# Reference MSA vs perturbed MSA: representative dataset SP/TC scores ----------

# Scores where same as rep50 vs different from rep50 (don't care what other model)
models %>%
  filter(num == 50) %>%
  rename(rep50_model = best_model) %>%
  select(-num, -best_matrix) %>%
  right_join(models) %>%
  filter(num!=50) %>%
  mutate(same_as_rep50 = rep50_model == best_model) %>%
  select(-rep50_model, -best_model, -best_matrix) %>%
  filter(num!=50) -> models_vs_rep50

models_vs_rep50 %>%
  #filter(ic_type == "AIC") %>%
  group_by(id, ic_type, dataset, datatype) %>% 
  tally(same_as_rep50, name = "n_same_rep50_model") -> n_models_same_as_rep50

models_vs_rep50 %>%
  left_join(scores %>% select(-ref_num) %>% rename(num = est_num)) %>%
  distinct() -> n_models_same_as_rep50_scores

# representative
representative <- "PF02311"
n_models_same_as_rep50_scores %>%
  filter(id == representative) %>%
  rename(SP = sp, TC = tc) %>%
  pivot_longer(SP:TC, names_to = "score_type", values_to = "score") %>%
  mutate(same_as_rep50 = ifelse(same_as_rep50 == TRUE, "Yes", "No")) %>%
  ggplot(aes(x = score_type, y = score, fill = same_as_rep50)) + 
    geom_jitter(pch = 21, position = position_jitterdodge(dodge.width = 0.8), alpha=0.8) + 
    facet_grid(cols = vars(datatype),
               rows = vars(ic_type)) +
    scale_fill_brewer(palette = "Set2", 
                      name = "Pertubed MSA model matches reference MSA model") +
    labs(x = "MSA score type", 
         y = "Score of a single perturbed MSA") +
    theme(legend.position = "bottom") -> sp_tc_representative_jitter
save_plot(file.path(output_path, "sp_tc_representative_jitter.pdf"), sp_tc_representative_jitter, base_width = 8, base_height = 4)
  
# Boxplot of mean SP and TC scores for perturbed MSAs --------------------------
models %>%
  filter(num == 50) %>%
  rename(rep50_model = best_model,
         rep50_matrix = best_matrix) %>%
  select(-num) %>%
  right_join(models) %>%
  filter(num!=50) %>%
  # ivrit makes the factors in the right order. anglit fail.
  mutate(same_model_rep50 = ifelse(rep50_model == best_model, "cen", "lo"),
         same_matrix_rep50 = ifelse(rep50_matrix == best_matrix, "cen", "lo")) %>%
  select(-rep50_model, -best_model, -best_matrix) %>%
  #filter(num!=50) %>%
  select(same_model_rep50, same_matrix_rep50, everything())-> same_as_rep50



# What about where ALL are rep50?
same_as_rep50 %>%
  select(-same_matrix_rep50) %>%
  filter(same_model_rep50 == "cen") %>%
  count(same_model_rep50, id, datatype, ic_type, name = "count_model_sameas_rep50") %>%
  filter(count_model_sameas_rep50 == 49) %>%
  inner_join(scores) %>%
  select(-same_model_rep50, -ref_num, -est_num) %>%
  group_by(id, datatype, ic_type) %>%
  summarize(mean_sp = mean(sp), mean_tc = mean(tc))%>%
  pivot_longer(mean_sp:mean_tc,names_to = "score_type", values_to = "mean_score") %>%
  mutate(same_as_rep50 = "allsame") -> mean_scores_all_same

n_models_same_as_rep50_scores %>%
  group_by(id, ic_type, dataset, datatype, same_as_rep50) %>%
  summarize(mean_sp = mean(sp), 
            mean_tc = mean(tc)) %>%
  ungroup()%>% 
  pivot_longer(mean_sp:mean_tc, names_to = "score_type", values_to = "mean_score") %>%
  mutate(same_as_rep50 = ifelse(same_as_rep50, "yes", "no")) %>%
  full_join(mean_scores_all_same) -> scores_plot_data

fill_levels <- c("All variant MSAs select the same model", 
                 "Perturbed MSA model matches reference MSA model", 
                 "Perturbed MSA model differs from reference MSA model")
scores_plot_data %>%
  mutate(same_as_rep50 = case_when(
            same_as_rep50 == "allsame" ~ fill_levels[1],
            same_as_rep50 == "yes" ~ fill_levels[2],
            same_as_rep50 == "no" ~ fill_levels[3]),
         score_type = ifelse(score_type == "mean_sp", "SP", "TC")
  ) %>%
  ggplot(aes(x = score_type, 
             y = mean_score, 
             fill = fct_relevel(same_as_rep50, fill_levels))) + 
    geom_boxplot(outlier.size = 0.2, size=0.3) + 
    facet_grid(cols = vars(datatype), 
               rows = vars(ic_type)) +
    scale_fill_brewer(palette = "Set2", name = "") + 
    xlab("MSA score measurement") + 
    ylab("Mean perturbed MSA scores") + 
    theme(axis.text.y = element_text(size = rel(0.8)),
          legend.position = "bottom", 
          legend.text = element_text(size = rel(0.62))) +
    guides(fill = guide_legend( nrow=1 ))-> scores_boxplot


save_plot(file.path(output_path, "scores_boxplot.png"), scores_boxplot, base_width = 8, base_height = 4)



## Model the scores:
scores_plot_data %>% filter(score_type == "mean_sp") -> sp_means
sp_means %>% filter(datatype == "AA") -> spaa
sp_means %>% filter(datatype == "NT") -> spnt
summary(lm( mean_score ~ same_as_rep50, data = spaa ))
summary(lm( mean_score ~  same_as_rep50, data = spnt ))


scores_plot_data %>% filter(score_type == "mean_tc") -> tc_means
tc_means %>% filter(datatype == "AA") -> tcaa
tc_means %>% filter(datatype == "NT") -> tcnt
summary(lm( mean_score ~ same_as_rep50, data = tcaa ))
summary(lm( mean_score ~  same_as_rep50, data = tcnt ))

