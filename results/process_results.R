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


## Create summary data frames ---------------------------------------------
# How many datasets are there? 1000 for each selectome and 236 PANDIT - yup!
models %>% 
  filter(ic_type == "AIC", num == 1) %>% 
  count(dataset, datatype, name = "total") -> number_of_datasets

# How many models per dataset?  
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_models") -> how_many_models

# How many matrices per dataset?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_matrices") -> how_many_matrices
  
# Percent of dataset variants with top model?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_model) %>%
  ungroup() %>%
  group_by(id, datatype, dataset, ic_type) %>%
  summarize(top_model_percent = max(n)/total_reps) %>%
  ungroup()-> percent_top_models

# Percent of dataset variants with top matrix?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  group_by(id, datatype, dataset, ic_type) %>%
  summarize(top_matrix_percent = max(n)/total_reps) %>%
  ungroup()-> percent_top_matrices



## Figures --------------------------------------------------------------


# Barplot of stability counts
how_many_models %>%
  mutate(stability = ifelse(n_models == 1, "Stable", "Unstable")) %>%
  group_by(datatype, dataset, ic_type) %>%
  count(stability) %>%
  ggplot(aes(x = stability, fill = ic_type, y = n)) + 
    geom_col(position = position_dodge(), color = "black", size = 0.3) + 
    geom_text(aes(label = n, y = n+37), position = position_dodge(width = 1), size=2.5) +
    facet_grid(datatype ~ dataset) + 
    scale_fill_brewer(name = "", palette = "Dark2") +
    labs(x = "Dataset stability", y = "Number of datasets") + 
    scale_y_continuous(limits=c(0,800)) +
    theme(legend.position = "bottom") -> stability_bar
ggsave(file.path(output_path, "stability_bar.pdf"), stability_bar, width = 8, height = 4)



# Histogram of the total number of models -----------------------------
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
ggsave(file.path(output_path, "nmodels_percentm0.pdf"), nmodels_percentm0, width = 12, height = 4)




full_join(how_many_models, how_many_matrices) %>%
  filter(n_models > 1, ic_type == "AIC") %>%
  mutate(qstability = ifelse(n_matrices == 1, "Same Q matrix", "Different Q matrices")) %>%
  # have to count for a geom_text
  count(dataset, datatype, qstability) %>%
  mutate(fudge = ifelse(datatype == "NT", n+30, n+15)) %>%
  ggplot(aes(x = dataset, y = n, fill = qstability)) + 
  geom_col(color = "black", size = 0.3, position = position_dodge()) + 
  geom_text(aes(label = n, y = fudge), size = 2.5, position = position_dodge(width = 1))+
  facet_wrap(vars(datatype), scales = "free_y") + 
  scale_fill_brewer(palette = "Dark2", name = "") +
  xlab("Dataset source") +
  ylab("Number of datasets") + 
  theme(legend.position = "bottom") ->qstability
ggsave(file.path(output_path, "qstability.pdf"), qstability, width = 8, height = 3)



#####################################################################
#####################################################################




nmodels_histogram(how_many_models, "AIC", n_models, "Number of best-fitting models") -> topleft 
nmodels_histogram(how_many_matrices, "AIC", n_matrices, "Number of best-fitting Q matrices") -> topright
percent_best_histogram(percent_top_models %>% filter(top_matrix_percent!=1), "AIC", top_model_percent,"Percent of variants with most common best-fitting model") -> bottomleft
percent_best_histogram(percent_top_matrices%>% filter(top_matrix_percent!=1), "AIC", top_matrix_percent,"Percent of variants with most common best-fitting Q matrix") -> bottomright

plot_grid(topleft+ ggtitle("All datasets"), topright+ ggtitle("All datasets"), bottomleft+ ggtitle("Unstable datasets"), bottomright+ ggtitle("Unstable datasets"), nrow=2, labels = "auto") -> maintext_histograms
save_plot(file.path(output_path, "maintext_histogram_panels.png"), maintext_histograms, base_width = 9, base_height =7)

stop()
 


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
  group_by(id, dataset, datatype, ic_type) %>% 
  tally(same_as_rep50, name = "n_same_rep50_model") -> n_models_same_as_rep50

models_vs_rep50 %>%
  left_join(scores %>% select(-ref_num) %>% rename(num = est_num)) %>%
  distinct() -> n_models_same_as_rep50_scores

# representative

x <- sample(n_models_same_as_rep50_scores$id, 1)
n_models_same_as_rep50_scores %>%
  filter(id == x) %>%
  pivot_longer(sp:tc, names_to = "score_type", values_to = "score") %>%
  ggplot(aes(x = score_type, y = score, fill = same_as_rep50)) + 
    geom_jitter(pch = 21, position = position_jitterdodge(dodge.width = )) + 
    facet_grid(datatype~ic_type) +
    scale_fill_brewer(palette = "Set2") 
"PF02311" # ALL BOTH COLORS!
"EMGT00050000009338"
"EMGT00050000001660"
"EMGT00050000002154"
"ENSGT00390000008961"

n_models_same_as_rep50_scores %>%
  group_by(id, dataset, datatype, ic_type, same_as_rep50) %>%
  summarize(SP = mean(sp), 
            TC = mean(tc)) %>%
  pivot_longer(SP:TC, names_to = "score_type", values_to = "mean_score") %>%
  mutate(same_as_rep50_char = if_else(same_as_rep50, "Same as reference MSA model", "Different from reference MSA model")) -> scores_vs_rep50_plotme

scores_vs_rep50_plotme %>%
  filter(datatype == "AA") -> scores_vs_rep50_plotme_aa

scores_vs_rep50_plotme %>%
  filter(datatype == "NT") -> scores_vs_rep50_plotme_nt


boxplot_score_rep50 <- function(df, title, legend_position){
  df %>%
    ggplot(aes(x = score_type, y = mean_score, fill = fct_relevel(same_as_rep50_char, "Same as reference MSA model"))) + 
    geom_boxplot(color = "black", outlier.size = 0.2, size = 0.3) +
    facet_grid(ic_type~dataset) + 
    scale_fill_brewer(palette = "Set2", name = "Selected model") + 
    xlab("MSA score measurement") + 
    ylab("Mean MSA scores") + 
    ggtitle(title) +
    theme(legend.position = legend_position)
}

boxplot_score_rep50(scores_vs_rep50_plotme_aa, "Protein alignments", "bottom") -> box_aa
boxplot_score_rep50(scores_vs_rep50_plotme_aa, "Nucleotide alignments", "none") -> box_nt
box_legend <- get_legend(box_aa)

plot_grid(box_aa + theme(legend.position = "none"), box_nt, nrow=1, labels="auto", scale=0.96) -> plot_nolegend
plot_grid(plot_nolegend, p12_legend, ncol=1, rel_heights = c(1, 0.1)) -> final_box

save_plot(file.path(output_path, "scores_rep50_model.png"), final_box, base_width = 12, base_height = 5)




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
  
  ggplot(aes(x = NT, y = AA)) + 
    geom_hex() +
    geom_abline() +
    facet_grid(ic_type~dataset)







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
