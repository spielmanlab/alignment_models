source("01_setup.R")
source("02_load_prepare_data.R")
source("03_build_glms.R")

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


# Histograms: how many models and percentage top model -------------------------
plot_howmanymodels(howmanymodels_plot_data, "AIC") -> bar_howmanymodels_aic
plot_percentm0(percent_top_models, "AIC") -> percentm0_aic

plot_grid(bar_howmanymodels_aic, 
          percentm0_aic,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0_aic
ggsave(file.path(output_path, "nmodels_percentm0_aic.png"), 
       nmodels_percentm0_aic, width = 12, height = 4)



# Build and visualize the GLMs -------------------------------------------------
source("build_plot_glms.R") 

# Boxplot of mean SP and TC scores for perturbed MSAs --------------------------

plot_scores_boxplot(scores_plot_data, "AIC") -> scores_boxplot_aic
save_plot(file.path(output_path, "scores_boxplot.png"), scores_boxplot_aic, base_width = 5, base_height = 3)





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
TukeyHSD(aov(mean_score ~ group, data = spaa )) %>% 
  broom::tidy() %>%
  



TukeyHSD(aov( mean_score ~  group, data = spnt )) %>% broom::tidy()


modelme %>% filter(score_type == "TC") -> tc_means
tc_means %>% filter(datatype == "AA") -> tcaa
tc_means %>% filter(datatype == "NT") -> tcnt
TukeyHSD(aov( mean_score ~ group, data = tcaa )) %>% broom::tidy()
TukeyHSD(aov( mean_score ~  group, data = tcnt )) %>% broom::tidy()

