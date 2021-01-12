
models <- read_csv("all_selected_models.csv")  
scores <- read_csv("all_alignment_scores.csv")
hamming <- read_csv("pairwise_hamming_distances.csv") %>% rename(id = dataname)
data_info <- read_csv("nsites_nseqs.csv") %>% rename(id = name)

## Create summary data frames ---------------------------------------------

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
