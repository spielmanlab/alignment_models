library(tidyverse)

## This function converts a directory of CSV files containing model selection information into a single tibble for all replicates
## NOTE: Assumes that the following headers are in each CSV: No.,Model,-LnL,df,AIC,AICc,BIC
## NOTE: Assumes each file is named <name>_alnversion_<number>_models.csv
process_all_csv <- function(path_to_csv)
{
  # List of all csv files in the given directory
  files <- dir(path = path_to_csv, pattern = "*.csv")
  tibble(filename = files) %>%
    mutate(file_contents = map(filename,
                               ~ read_csv(file.path(path_to_csv, .)))) %>%
    unnest() %>%
    separate(filename, c("name", "dummy", "number", "dummy2"), sep="_") %>%
    dplyr::select(-dummy, -dummy2, -No., -`-LnL`, -df) %>%
    gather(ic_type, ic_value, AIC, AICc, BIC) %>%
    group_by(name, number, ic_type) %>%
    mutate(ic_rank = rank(ic_value)) %>%
    filter(ic_rank == 1) %>%
    ungroup() %>%
    dplyr::select(name, number, Model, ic_type) -> ranked_models
  ranked_models
  
}

aa_path <- "selectome_aa_output/"
nt_path <- "selectome_nt_output/"
#aa_ranked_models <- process_all_csv(aa_path)
#nt_ranked_models <- process_all_csv(nt_path)
#write_csv(aa_ranked_models, "aa_ranked_models.csv")
#write_csv(nt_ranked_models, "nt_ranked_models.csv")


aa_ranked_models <- read_csv("aa_ranked_models.csv")
nt_ranked_models <- read_csv("nt_ranked_models.csv")

head(aa_ranked_models)
aa_head()
aa_head = "ENSGT00390000000018.Euteleostomi.003.aa.fas"

aa_ranked_models %>%
  filter(name == aa_head) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic()

dummynum <- aa_ranked_models %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>% 
  rename(number_models = n ) %>%
  group_by(name, number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n)

head(e)

aa_head_e = "ENSGT00390000000018.Euteleostomi.003.aa.fas"

aa_ranked_models %>%
  filter(name == aa_head_e) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic()

hopefully_one = "ENSGT00530000063305.Euteleostomi.009.aa.fas"

aa_ranked_models %>%
  filter(name == hopefully_one) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic()


#color vector i GUESS

cols <- c("AIC" = "limegreen", "AICc" = "green3", "BIC" = "darkgreen")

aa_ranked_models %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>%
  rename(number_models = n ) %>%
  group_by(number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n) %>%
  ggplot(aes(x = number_models, y = name, fill = ic_type)) + 
  geom_col(color = "black", width = 1) + 
  #ggtitle("Protein Model Selection") +
  geom_text(aes(x = number_models, y = name + 1, label = name), size = 8, position = position_dodge(width = 1),
            vjust = -0.2) +
  facet_wrap(~ic_type)+ 
  theme_classic() + scale_x_continuous(name = "Number of Models per Dataset") +
  scale_y_continuous(name = "Number of Datasets") +
  scale_fill_manual(values = cols) +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5),
        axis.text= element_text(size = 35),  axis.title = element_text(size = 40),
        strip.text = element_text(size = 35)) -> num_aa_models_plot

ggsave("num_aa_plot3.pdf", num_aa_models_plot, width = 14.7, height = 10.36, units = "in")

cols2 <- c("AIC" = "lightblue1", "AICc" = "deepskyblue1", "BIC" = "dodgerblue3")


nt_ranked_models %>%
  group_by(name, Model, ic_type) %>% 
  tally() %>% 
  ungroup() %>% 
  select(-n) %>% 
  group_by(name, ic_type) %>% 
  tally() %>%
  rename(number_models = n ) %>%
  group_by(number_models, ic_type) %>% 
  tally() %>% 
  rename(name = n) %>%
  ggplot(aes(x = number_models, y = name, fill = ic_type)) + 
  geom_col(color = "black", width = 1) + 
  #ggtitle("Protein Model Selection") +
  geom_text(aes(x = number_models, y = name + 1, label = name), size = 8, position = position_dodge(width = 1),
            vjust = -0.2) +
  facet_wrap(~ic_type)+ 
  theme_classic() + scale_x_continuous(name = "Number of Models per Dataset") +
  scale_y_continuous(name = "Number of Datasets") +
  scale_fill_manual(values = cols2) +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5),
        axis.text= element_text(size = 35),  axis.title = element_text(size = 40),
        strip.text = element_text(size = 35)) -> num_nt_models_plot



ggsave("num_nt_plot2.pdf", num_nt_models_plot, width = 14.7, height = 10.36, units = "in")


# i = 0
# for (plot1 in c(num_nt_models_plot, num_aa_models_plot)) {
#   ggsave(str(i) + "output.pdf", plot1)
#          i = i + 1
# }
# i = 0
# for (plot1 in c(num_nt_models_plot, num_aa_models_plot)) {
#   ggsave(paste0(i, "output.pdf"), plot1)
#          i = i + 1
# }
# 
# 
# ggsave("output.pdf", num_nt_models_plot) # add args like width = .., height = ..
# 
