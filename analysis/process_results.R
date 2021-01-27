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


# Boxplot of mean SP and TC scores for perturbed MSAs --------------------------
models %>%
  filter(num == reference_msa_num) %>%
  select(-num, -best_matrix) %>%
  rename(ref_msa_model = best_model)-> ref_msa_models


how_many_models %>%
  mutate(stability = ifelse(n_models == 1, T, F)) -> stability_models
stability_models %>%
  filter(stability == T) %>%
  select(id, datatype, dataset, ic_type) %>%
  distinct() -> stable_ids
stability_models %>%
  filter(stability == F) %>%
  select(id, datatype, dataset, ic_type) %>%
  distinct() -> unstable_ids


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
same_as_rep50 %>%
  right_join(stable_ids) %>%
  # confirmed, no rows removed:
  filter(same_model_rep50 =="cen") %>%
  select(-num, -same_model_rep50, -best_model) %>%
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

scores_plot_data %>%
  # all IC are statistically same
  filter(ic_type == "AIC") %>%
  ggplot(aes(x = score_type, 
             y = mean_score, 
             fill = fct_relevel(group_levels, fill_levels))) + 
  geom_boxplot(outlier.size = 0.1, size=0.3) + 
  facet_wrap(vars(datatype)) +
  scale_fill_brewer(palette = "Set2", name = "") + 
  xlab("MSA score measurement") + 
  ylab("Mean scores") + 
  theme(axis.text.y = element_text(size = rel(0.9)),
        legend.position = "bottom", 
        legend.text = element_textbox()) +
  guides(fill = guide_legend( nrow=1 )) -> scores_boxplot

save_plot(file.path(output_path, "scores_boxplot.png"), scores_boxplot, base_width = 5, base_height = 3)



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

