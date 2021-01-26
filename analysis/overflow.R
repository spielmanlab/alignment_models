############################### ANALYSIS OVERFLOW ##################################





percent_best_histogram <- function(df, ic, x, xlabel)
{
  df %>%
    filter(ic_type == ic, 
           {{x}} < 1) %>%
    ggplot(aes(x = {{x}}, fill = dataset)) + 
    geom_histogram(binwidth = 0.1, color = "black") + 
    facet_grid(dataset ~ datatype, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    scale_x_reverse(breaks=rev(seq(0, 1, 0.2))) +
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
    facet_grid(datatype ~ dataset, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    scale_x_continuous(breaks=1:10) +
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


boxplot_score_rep50 <- function(df, title, legend_position){
  df %>%
    ggplot(aes(x = score_type, y = mean_score, fill = fct_relevel(same_as_rep50_char, "Same as reference MSA model"))) + 
    geom_boxplot(color = "black", outlier.size = 0.3, size = 0.2) +
    facet_grid(ic_type~dataset) + 
    scale_fill_brewer(palette = "Set2", name = "Selected model") + 
    xlab("MSA score measurement") + 
    ylab("Mean MSA scores") + 
    ggtitle(title) +
    theme(legend.position = legend_position)
}


nmodels_histogram(how_many_models, "AIC", n_models, "Number of best-fitting models") -> topleft 
nmodels_histogram(how_many_matrices, "AIC", n_matrices, "Number of best-fitting Q matrices") -> topright
percent_best_histogram(percent_top_models %>% filter(top_matrix_percent!=1), "AIC", top_model_percent,"Percent of variants with most common best-fitting model") -> bottomleft
percent_best_histogram(percent_top_matrices%>% filter(top_matrix_percent!=1), "AIC", top_matrix_percent,"Percent of variants with most common best-fitting Q matrix") -> bottomright

plot_grid(topleft+ ggtitle("All datasets"), topright+ ggtitle("All datasets"), bottomleft+ ggtitle("Unstable datasets"), bottomright+ ggtitle("Unstable datasets"), nrow=2, labels = "auto") -> maintext_histograms
save_plot(file.path(output_path, "maintext_histogram_panels.png"), maintext_histograms, base_width = 9, base_height =7)



plot_grid(nmodels_histogram(how_many_models, "AIC", n_models, "Number of best-fitting models") , 
          nmodels_histogram(how_many_models, "AICc", n_models, "Number of best-fitting models"), 
          nmodels_histogram(how_many_models, "BIC", n_models, "Number of best-fitting models"), 
          labels = "auto", nrow = 1) -> nmodels_histograms
save_plot(file.path(output_path, "models_per_id.png"), nmodels_histograms, base_width = 12, base_height = 5)





plot_grid(nmodels_histogram(how_many_matrices, "AIC", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "AICc", n_matrices, "Number of best-fitting model matrices"), 
          nmodels_histogram(how_many_matrices, "BIC", n_matrices, "Number of best-fitting model matrices"), 
          labels = "auto", nrow = 1) -> nmatrices_histograms
save_plot(file.path(output_path, "matrices_per_id.png"), nmatrices_histograms, base_width = 12, base_height = 5)



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
save_plot(file.path(output_path, "percent_common_model.png"), percent_best_model_histograms, base_width = 14, base_height = 6)

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
save_plot(file.path(output_path, "percent_common_matrix.png"), percent_best_matrix_histograms, base_width = 14, base_height = 6)






### THIS ONE!!!!
## It tells us: AA are more likely than NT to have a stable matrix. When differing models, often it's the same matrix with different I/G/F.
# By contrast, the NT values are quite similar for matrix vs model, suggesting that when differing models, so different models on the whole are not unlikely to be selected.
# This is interesting and suggests a lack of NT alignment stability compared to AA alignment stability, as there are more AA models compared to NT models.
percent_top_models %>%
  mutate(stability = if_else(top_model_percent == 1, "stable", "unstable")) %>%
  count(datatype, dataset, stability, ic_type) %>%
  left_join(number_of_datasets) %>%
  mutate(percent = n/total) %>%
  select(-n, -total) %>%
  filter(ic_type == "AIC") %>%
  mutate(context = "Model stability") %>%
  bind_rows(matrix_stability_aic) %>%
  filter(stability == "stable") %>%
  ggplot(aes(x = datatype, y = percent, fill = context)) + 
  geom_col(position = position_dodge(),color = "grey20") + 
  geom_text(aes(label = round(percent, 2), y =percent+0.03), position = position_dodge(width=1), size=2.75)+
  facet_wrap(~dataset) + 
  xlab("Datatype") + ylab("Percent of datasets") +
  scale_fill_brewer(palette = "Set2", name = "") + 
  theme(legend.position = "bottom")


# any kind of difference
percent_top_models %>%
  mutate(stability = if_else(top_model_percent == 1, "stable", "unstable")) %>%
  count(datatype, dataset, stability, ic_type) %>%
  left_join(number_of_datasets) %>%
  mutate(percent = n/total) %>%
  select(-n, -total) %>%
  filter(ic_type == "AIC") %>%
  ggplot(aes(x = datatype, y = percent, fill = stability)) + 
  geom_col(position = position_dodge()) + 
  geom_text(aes(label = round(percent, 2), y =percent+0.03), position = position_dodge(width=1), size=2.5)+
  facet_grid(~dataset) + 
  xlab("Datatype") + ylab("Percent of datasets") +
  scale_fill_brewer(palette = "Set2", name = "Selected model stability") +
  theme(legend.position = "bottom") + 
  geom_hline(yintercept = 0.5, color = "black")






# Plot: scatterplot of percent model vs percent matrix. Not sure that this communicates well.

#percent_top_matrices %>% 
#  left_join(percent_top_models) %>% 
#  filter(ic_type == "AIC") %>%
#  ggplot(aes(x = top_model_percent, y = top_matrix_percent, color = dataset)) + 
#  geom_point(alpha = 0.5) + 
#  facet_grid(datatype~dataset) + 
#  xlim(0.1, 1) + ylim(0.1,1) + 
#  scale_color_brewer(palette = "Set1")
# top vertical line: a bunch of models, same matrix
# diagonal line: top model is a distinct matrix
# 

# Plot: NT vs AA?
# Total nt models: 88
# Total aa models: 168
percent_top_models %>%
  group_by(dataset, ic_type) %>%
  pivot_wider(names_from = "datatype", values_from = "top_model_percent") %>%
  drop_na() %>%
  summarize(corr = cor(AA, NT), 
            p.value = cor.test(AA, NT)$p.value)

#              dataset      ic_type     corr      p.value
#  <chr>        <chr>      <dbl>        <dbl>
#1 Drosophila   AIC      0.168   0.0000000969
#2 Drosophila   AICc     0.141   0.00000708  
#3 Drosophila   BIC      0.100   0.00149     
#4 Euteleostomi AIC     -0.00149 0.963       
#5 Euteleostomi AICc     0.0206  0.515       
#6 Euteleostomi BIC      0.0673  0.0333      
#7 PANDIT       AIC      0.0761  0.244       
#8 PANDIT       AICc     0.127   0.0519      
#9 PANDIT       BIC      0.121   0.0631 



# q matrices
percent_top_matrices %>%
  mutate(stability = if_else(top_matrix_percent == 1, "stable", "unstable")) %>%
  count(datatype, dataset, stability, ic_type) %>%
  left_join(number_of_datasets) %>%
  mutate(percent = n/total) %>%
  select(-n, -total) %>%
  filter(ic_type=="AIC") %>%
  mutate(context = "Q matrix stability") -> matrix_stability_aic


percent_top_models %>%
  mutate(stability = if_else(top_model_percent == 1, "stable", "unstable")) %>%
  count(datatype, dataset, stability, ic_type) %>%
  left_join(number_of_datasets) %>%
  mutate(percent = n/total) %>%
  select(-n, -total) %>%
  filter(ic_type == "AIC") %>%
  mutate(context = "Model stability") %>%
  bind_rows(matrix_stability_aic) %>%
  ggplot(aes(x = datatype, y = percent, fill = stability)) + 
  geom_col(position = position_dodge(),color = "grey20") + 
  geom_text(aes(label = round(percent, 2), y =percent+0.03), position = position_dodge(width=1), size=2.75)+
  facet_grid(context~dataset) + 
  xlab("Datatype") + ylab("Percent of datasets") +
  scale_fill_brewer(palette = "Set2", name = "") + 
  theme(legend.position = "bottom")




### Stability and datatype are HIGHLY correlated.

### PANDIT
observed_table <- matrix(c(91,145,184,52), nrow = 2, ncol = 2, byrow = T)
rownames(observed_table) <- c('NT', 'AA')
colnames(observed_table) <- c('stable', 'unstable')
observed_table
chisq.test(observed_table) # P<2.2e-16

### Drosophila
observed_table <- matrix(c(377,623,708,292), nrow = 2, ncol = 2, byrow = T)
rownames(observed_table) <- c('NT', 'AA')
colnames(observed_table) <- c('stable', 'unstable')
observed_table
chisq.test(observed_table) # P<2.2e-16

### Euteleostomi
observed_table <- matrix(c(582, 418, 868, 132), nrow = 2, ncol = 2, byrow = T)
rownames(observed_table) <- c('NT', 'AA')
colnames(observed_table) <- c('stable', 'unstable')
observed_table
chisq.test(observed_table) # P<2.2e-16

percent_top_matrices %>%
  group_by(dataset, ic_type) %>%
  pivot_wider(names_from = "datatype", values_from = "top_matrix_percent") %>%
  drop_na() %>%
  summarize(corr = cor(AA, NT), 
            p.value = cor.test(AA, NT)$p.value)

#  dataset      ic_type     corr p.value
#  <chr>        <chr>      <dbl>   <dbl>
#1 Drosophila   AIC      0.0842  0.00769
#2 Drosophila   AICc     0.0831  0.00858
#3 Drosophila   BIC      0.0134  0.672  
#4 Euteleostomi AIC      0.0128  0.686  
#5 Euteleostomi AICc     0.0270  0.394  
#6 Euteleostomi BIC      0.0119  0.707  
#7 PANDIT       AIC      0.200   0.00207
#8 PANDIT       AICc     0.187   0.00390
#9 PANDIT       BIC     -0.00559 0.932  




# Analysis: Among IC, do we see same or different number of models? -------------------------------

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
  geom_point(pch = 22, color ="black", size=20) +
  #geom_rect(color = "black")+ 
  geom_text(aes(label = round(combo_percent,3),
                color = combo_percent <= 0.15), # neat trick! scale_color_manual has it
            size = 3) + 
  facet_grid(datatype ~ dataset) +
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