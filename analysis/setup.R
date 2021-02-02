# Libraries -----------------------
library(tidyverse)
library(magrittr) # %<>%
library(cowplot)
library(ggtext)
library(pROC)

theme_set(theme_light() + 
            theme(strip.text = element_text(color = "black"),
                  legend.position = "bottom"
            )
)

total_reps <- 50
reference_msa_num <- 50
lb_score_group <- 3
ub_score_group <- 46
output_path <- "figures/"
