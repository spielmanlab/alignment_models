library(tidyverse)
library(cowplot)


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
aa_ranked_models <- process_all_csv(aa_path)
nt_ranked_models <- process_all_csv(nt_path)

unique(aa_ranked_models$Model)

unique(aa_ranked_models$name) 


aa1_unique = "ENSGT00520000055637.Euteleostomi.001.aa.fas"

### one model
aa_ranked_models %>%
  filter(name == aa1_unique) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic() -> one_model_plot

ggsave("one_model.pdf", one_model_plot)

two_model = "ENSGT00390000018612.Euteleostomi.001.aa.fas"

### two model
aa_ranked_models %>%
  filter(name == two_model) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic() 

### three model
aa3_unique = "ENSGT00390000013494.Euteleostomi.001.aa.fas"
aa_ranked_models %>%
  filter(name == aa3_unique) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic() 


test = "ENSGT00390000005703.Euteleostomi.001.aa.fas"

aa_ranked_models %>%
  filter(name == test) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge()) + theme_classic() 

for (name in unique(aa_ranked_models$name)) {
  readline(name)
}


unique(nt_ranked_models$name)

one_model = "ENSGT00390000000455.Euteleostomi.001.nt.fas"

### one model
nt_ranked_models %>%
  filter(name == one_model) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() +
  scale_y_continuous(name = "Number of Alignments") + scale_fill_brewer(palette = "Set1") +
  labs(fill = "Information Criterion") +
  theme(legend.position = "top",
        legend.background = element_rect(fill = "lightblue", size = 0.5, linetype = "solid"),
        axis.title = element_text(size = 17), axis.text = element_text(size = 9.3),
        legend.title = element_text(size = 13),
        legend.text = element_text(size = 11)) -> new_one_nt_model

ggsave("one_nt_model.pdf", new_one_nt_model, width = 7, height = 5, units = "in")


three_model = "ENSGT00410000025793.Euteleostomi.001.nt.fas"
### three model

nt_ranked_models %>%
  filter(name == three_model) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() +
  scale_y_continuous(name = "Number of Alignments") + scale_fill_brewer(palette = "Set1") +
  labs(fill = "Information Criterion") +
  theme(legend.position = "top",
        legend.background = element_rect(fill = "lightblue", size = 0.5, linetype = "solid"),
        axis.title = element_text(size = 17), axis.text = element_text(size = 9.3),
        legend.title = element_text(size = 13),
        legend.text = element_text(size = 11)) -> new_nt_three_model


ggsave("three_nt_model.pdf", new_nt_three_model, width = 7, height = 5, units = "in") 



six_nt_model = "ENSGT00390000008002.Euteleostomi.001.nt.fas"

### 6 models
nt_ranked_models %>%
  filter(name == six_nt_model) %>%
  ggplot(aes(x = Model, fill = ic_type)) + geom_bar(position = position_dodge(), color = "black") + theme_classic() +
  scale_y_continuous(name = "Number of Alignments") + scale_fill_brewer(palette = "Set1") +
  labs(fill = "Information Criterion") +
  theme(legend.position = "top",
        legend.background = element_rect(fill = "lightblue", size = 0.5, linetype = "solid"),
        axis.title = element_text(size = 17), axis.text = element_text(size = 9.3),
        legend.title = element_text(size = 13),
        legend.text = element_text(size = 11)) -> new_nt_six_model


ggsave("six_nt_model.pdf", new_nt_six_model, width = 7, height = 5, units = "in")

legend <- cowplot::get_legend(new_nt_six_model)
grid.newpage()
grid.draw(legend)


