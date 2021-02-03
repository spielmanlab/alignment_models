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


# Functions


plot_howmanymodels <- function(df, ic)
{
  df %>%
    filter(ic_type == ic) %>%
    ggplot(aes(x = n_models, y = percent, fill = dataset)) + 
    geom_col(color = "black", size = 0.3) + 
    geom_text(aes(label = percent, y = percent+0.05), size = 2.5)+
    facet_grid(datatype ~ dataset, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    xlab("Unique selected models per dataset") +
    ylab("Percent of unstable datasets") + 
    theme(legend.position = "none")
}


plot_percentm0 <- function(df, ic)
{
  df %>%
    filter(ic_type == ic) %>%
    filter(top_model_percent < 1, ic_type == ic) %>%
    ggplot(aes(x = top_model_percent, fill = dataset)) + 
    geom_histogram(bins = 20, color = "black", size = 0.3) +
    facet_grid(datatype~dataset, scales = "free") + 
    scale_fill_brewer(palette = "Set1") +
    scale_x_reverse(breaks=rev(seq(0, 1, 0.2))) +
    theme() +
    xlab("Percentage of MSA variants selecting the M<sup>0</sup> model")+
    ylab("Number of datasets") +
    theme(legend.position = "none", 
          axis.title.x = element_textbox()) 
}


plot_scores_boxplot <- function(df, ic)
{
  df %>%
    filter(ic_type == ic) %>%
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
    guides(fill = guide_legend( nrow=1 ))
}
