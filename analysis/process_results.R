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
reference_msa_num <- 50
lb_score_group <- 3
ub_score_group <- 46
output_path <- "figures/"

# Load and clean data ----------------------------------------------------------
source("load_prepare_data.R")
source("plot_functions.R") # Functions to make different IC versions of certain plots


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
ggsave(file.path(output_path, "stability_bar.png"), stability_bar, width = 8, height = 4)


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
ggsave(file.path(output_path, "qstability.png"), qstability, width = 8, height = 3)

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
  ylab("Percent of unstable datasets") + 
  theme(legend.position = "bottom") -> si_qstability
ggsave(file.path(output_path, "si_qstability.png"), si_qstability, width = 8, height = 4)

# Histograms: how many models and percentage top model -------------------------
how_many_models %>%
  filter(n_models >1) %>%
  mutate(n_models = ifelse(n_models <=5, n_models, ">5")) %>%
  mutate(n_models = factor(n_models, levels=c(1:5, ">5"))) %>%
  # have to count for a geom_text
  count(dataset, datatype, n_models, ic_type, name = "n_datasets") %>%
  group_by(dataset, ic_type, datatype) %>%
  mutate(total = sum(n_datasets)) %>%
  ungroup() %>%
  mutate(percent = round(n_datasets/total,3)) -> howmanymodels_plot_data

plot_howmanymodels(howmanymodels_plot_data, "AIC") -> bar_howmanymodels_aic
plot_percentm0(percent_top_models, "AIC") -> percentm0_aic

plot_howmanymodels(howmanymodels_plot_data, "BIC") -> bar_howmanymodels_bic
plot_percentm0(percent_top_models, "BIC") -> percentm0_bic

plot_howmanymodels(howmanymodels_plot_data, "AICc") -> bar_howmanymodels_aicc
plot_percentm0(percent_top_models, "AICc") -> percentm0_aicc


plot_grid(bar_howmanymodels_aic, 
          percentm0_aic,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0_aic
ggsave(file.path(output_path, "nmodels_percentm0_aic.png"), 
       nmodels_percentm0_aic, width = 12, height = 4)

plot_grid(bar_howmanymodels_bic, 
          percentm0_bic,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0_bic
ggsave(file.path(output_path, "si_nmodels_percentm0_bic.png"), 
       nmodels_percentm0_bic, width = 12, height = 4)

plot_grid(bar_howmanymodels_aicc, 
          percentm0_aicc,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0_aicc
ggsave(file.path(output_path, "si_nmodels_percentm0_aicc.png"), 
       nmodels_percentm0_aicc, width = 12, height = 4)


# Build and visualize the GLMs -------------------------------------------------
source("build_plot_glms.R") 

# Boxplot of mean SP and TC scores for perturbed MSAs --------------------------
models %>%
  filter(num == reference_msa_num) %>%
  select(-num, -best_matrix) %>%
  rename(ref_msa_model = best_model)-> ref_msa_models

models %>%
  filter(num!=50) %>%
  left_join(ref_msa_models) %>%
  select(-best_matrix) %>%
  rename(est_num = num) %>%
  inner_join(unstable_ids) %>%
  inner_join(scores) %>%
  select(-ref_num) %>%
  mutate(group = ifelse(ref_msa_model == best_model, "matches", "differs")) %>%
  select(-best_model, -ref_msa_model) -> unstable_group_scores

unstable_group_scores %>%
  count(id, dataset, datatype, ic_type, group) %>%
  filter(between(n, lb_score_group, ub_score_group)) %>%
  inner_join(unstable_group_scores) %>%
  group_by(id, dataset, datatype, ic_type, group) %>%
  summarize(mean_sp = mean(sp),
            mean_tc = mean(tc)) %>%
  ungroup() -> unstable_mean_scores

# stable ids
ref_msa_models %>%
  right_join(stable_ids) %>%
  # confirmed, no rows removed:
  filter(ref_msa_model !="cen") %>%
  select(-ref_msa_model) %>%
  left_join(scores) %>% 
  select(-ref_num, -est_num) %>%
  group_by(id, dataset, datatype, ic_type) %>%
  summarize(mean_sp = mean(sp), 
            mean_tc = mean(tc)) %>%
  mutate(group = "stable") %>%
  ungroup()-> stable_mean_scores


fill_levels <- c("Stable dataset", 
                 "Matches M<sub>ref</sub>", 
                 "Differs from M<sub>ref</sub>")

bind_rows(unstable_mean_scores, stable_mean_scores) %>%
  pivot_longer(mean_sp:mean_tc, names_to = "score_type", values_to = "mean_score") %>%
  mutate(group_levels = case_when(
    group == "stable" ~ fill_levels[1],
    group == "matches" ~ fill_levels[2],
    group == "differs" ~ fill_levels[3]),
    score_type = ifelse(score_type == "mean_sp", "SP", "TC")
  ) -> scores_plot_data

plot_scores_boxplot(scores_plot_data, "AIC") -> scores_boxplot_aic
plot_scores_boxplot(scores_plot_data, "BIC") -> scores_boxplot_bic
plot_scores_boxplot(scores_plot_data, "AICc") -> scores_boxplot_aicc
save_plot(file.path(output_path, "scores_boxplot.png"), scores_boxplot_aic, base_width = 5, base_height = 3)

scores_boxplot_si <- plot_grid(plot_scores_boxplot(scores_plot_data, "BIC") + ggtitle("BIC"), 
                               plot_scores_boxplot(scores_plot_data, "AICc") + ggtitle("AICc"), 
                               nrow = 1, 
                               scale = 0.97)
save_plot(file.path(output_path, "si_scores_boxplot.png"), scores_boxplot_si, base_width = 9, base_height = 3)



## Model the scores with some tukeying
### ALL ic NS
### ALL differs/matches NS
### ALL stable significantly higher than both differs and matches
scores_plot_data %>% 
  filter(ic_type == "AIC") %>%
  mutate(group = factor(group, levels=c("matches", "differs", "stable"))) -> modelme
modelme %>% filter(score_type == "SP") -> sp_means
sp_means %>% filter(datatype == "AA") -> spaa
sp_means %>% filter(datatype == "NT") -> spnt
TukeyHSD(aov(mean_score ~ group, data = spaa )) %>% broom::tidy()
TukeyHSD(aov( mean_score ~  group, data = spnt )) %>% broom::tidy()


modelme %>% filter(score_type == "TC") -> tc_means
tc_means %>% filter(datatype == "AA") -> tcaa
tc_means %>% filter(datatype == "NT") -> tcnt
TukeyHSD(aov( mean_score ~ group, data = tcaa )) %>% broom::tidy()
TukeyHSD(aov( mean_score ~  group, data = tcnt )) %>% broom::tidy()

