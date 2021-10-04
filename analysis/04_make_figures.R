#source("01_setup.R")
#source("02_load_prepare_data.R")
#source("03_build_glms.R")

# Barplot of model stability counts --------------------------------------------
how_many_models %>%
  mutate(stability = ifelse(n_models == 1, "Stable", "Unstable")) %>%
  group_by(datatype, dataset, ic_type) %>%
  count(stability) %>%
  full_join(number_of_datasets) %>%
  mutate(n = round(n/total, 2)) %>%
  filter(stability == "Stable") %>%
  ggplot(aes(x = datatype, fill = ic_type, y = n)) + 
  geom_col(position = position_dodge(), color = "black", size = 0.3) + 
  geom_text(aes(label = n, y = n+.03), position = position_dodge(width = 1), size=2.25) +
  facet_grid(~ dataset) + 
  scale_fill_viridis_d(name = "") +
  labs(x = "Data type", y = "Proportion of datasets that are stable") + 
  scale_y_continuous(limits=c(0,1)) +
  theme(legend.position = "bottom", 
        panel.grid.minor.y = element_blank(), 
        axis.title.y = element_text(size = rel(0.8)),
        legend.key.size = unit(0.4, "cm")) -> stability_bar
ggsave(file.path(output_path, "stability_bar.png"), stability_bar, width = 6, height = 3)


# Barplot of matrix stability for n_models >1 with AIC -------------------------
full_join(how_many_models, how_many_matrices) %>%
  filter(n_models > 1, ic_type == "AIC") %>%
  mutate(qstability = ifelse(n_matrices == 1, "Same Q matrix", "Different Q matrices")) %>%
  # have to count for a geom_text
  count(dataset, datatype, qstability) %>%
  group_by(dataset, datatype) %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  filter(qstability == "Same Q matrix") %>%
  mutate(p = round(n/total, 2)) %>%
  mutate(fudge = p+0.02) %>%
  ggplot(aes(x = datatype, y = p, fill = dataset)) + 
  geom_col(color = "black", size = 0.3, position = position_dodge()) + 
  geom_text(aes(label = p, y = fudge), size = 2.5, position = position_dodge(width = 1))+
  scale_fill_viridis_d(name = "", option = "magma") +
  xlab("Data Type") +
  ylab("Proportion of unstable datasets\nwith a stable Q matrix") + 
  theme(legend.position = "bottom",
        axis.title.y = element_text(size = rel(0.8)),
        panel.grid.minor.y = element_blank(),
        legend.key.size = unit(0.4, "cm")) -> qstability
ggsave(file.path(output_path, "qstability.png"), qstability, width = 4, height = 3)


# Histograms: how many models and percentage top model -------------------------
plot_howmanymodels(howmanymodels_plot_data, "AIC") -> bar_howmanymodels_aic
plot_percentm0(percent_top_models, "AIC") -> percentm0_aic

plot_grid(bar_howmanymodels_aic, 
          percentm0_aic,
          nrow=1, labels = "auto", scale = 0.95) -> nmodels_percentm0_aic
ggsave(file.path(output_path, "nmodels_percentm0_aic.png"), 
       nmodels_percentm0_aic, width = 12, height = 4)



# Boxplot of mean SP and TC scores for perturbed MSAs --------------------------

plot_scores_boxplot(scores_plot_data, "AIC") -> scores_boxplot_aic
save_plot(file.path(output_path, "scores_boxplot.png"), scores_boxplot_aic, base_width = 5, base_height = 3)

