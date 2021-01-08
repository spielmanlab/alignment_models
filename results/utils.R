
process_raw_models <- function(df)
{
  df %>%
    separate(name, into=c("id", "dataset", "trash"), sep = "\\.") %>%
    replace_na(list(dataset = "PANDIT"))  %>%
    select(-trash) %>%
    group_by(id, datatype) %>%
    mutate(num = 1:n()) %>% 
    ungroup() %>%
    pivot_longer(AIC:BIC, 
                 names_to = "ic_type", 
                 values_to = "best_model") %>%
    mutate(best_matrix = str_replace(best_model, "\\+.+", ""))
}


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
