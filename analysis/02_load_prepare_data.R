
models <- read_csv("../results/all_selected_models.csv")  
scores <- read_csv("../results/all_alignment_scores.csv")
hamming <- read_csv("../results/pairwise_hamming_distances.csv") %>% rename(id = dataname)
data_info <- read_csv("../results/nsites_nseqs.csv") %>% rename(id = name)
guidance_raw <- read_csv("../results/final_guidance_scores.csv")

# clean the guidance csv
guidance_raw %>%
  separate(fullid, into=c("id", "dataset", "datatype"), sep = "\\.") %>%
  replace_na(list(dataset = "PANDIT")) -> guidance_raw2
guidance_raw2 %>%
  filter(dataset == "PANDIT") %>%
  separate(id, into=c("id", "datatype"), sep = "_") -> guidance_pandit

guidance_raw2 %>%
  filter(dataset != "PANDIT") %>%
  mutate(datatype = str_replace(datatype, "001_", "")) %>%
  bind_rows(guidance_pandit) -> guidance

data_info <- full_join(data_info, guidance)


# Process raw models
models %<>%
  separate(name, into=c("id", "dataset", "trash"), sep = "\\.") %>%
  replace_na(list(dataset = "PANDIT"))  %>%
  select(-trash) %>%
  group_by(id, datatype) %>%
  mutate(num = 1:n()) %>% 
  ungroup() %>%
  pivot_longer(AIC:BIC, 
               names_to = "ic_type", 
               values_to = "best_model") %>%
  # note: this replace has a warning and it's fine
  mutate(best_matrix = str_replace(best_model, "\\+.+", ""))


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

# to plot how many models
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


# How many matrices per id?
models %>%
  group_by(id, datatype, dataset, ic_type) %>%
  count(best_matrix) %>%
  ungroup() %>%
  count(id, datatype, dataset, ic_type, name = "n_matrices") -> how_many_matrices

# Percent of id variants with top model?
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

# Who is stable vs unstable?
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

## Prepare data for plotting scores ---------------
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

