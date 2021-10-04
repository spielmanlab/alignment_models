## Logistic regression to explain stability ------------------------------------

## Functions for modeling number of models/stability ----
logit_stability <- function(df)
{
  glm(stable ~  mean_hamming + mean_guidance_score + nseq + mean_nsites, data = df, family = "binomial")
}

tidyci <- function(fit)
{
  broom::tidy(fit, conf.level = conf_level, conf.int = TRUE) # uses 95 CI
}


# Functions for modeling sp and tc scores -------------------
tukey_sp_tc <- function(df)
{
  TukeyHSD(aov(mean_score ~ group, data = df), conf.level = conf_level) %>%
    broom::tidy()
}


clean_tukey <- function(tukey_output, datatype, scoretype)
{
  tukey_output %>%
    rowwise() %>%
    mutate(estimate = glue::glue(round(estimate, 3),
                                 " (", 
                                 round(conf.low, 3),
                                 ", ", 
                                 round(conf.high, 3),
                                 ")")) %>%
    select(-term, -null.value, -conf.high, -conf.low) %>% 
    select(Datatype = datatype,
           `Score type` = score_type, 
           Comparison = contrast, 
           `Effect size (99% CI)` = estimate, 
           `Adjusted P-value` = adj.p.value)
}



## Prep data ---------------------------
coeff_levels <- rev(c("mean_guidance_score", "mean_hamming", "mean_nsites", "nseq"))
coeff_labels <- rev(c("Mean GUIDANCE score",  "Mean edit distance",  "Mean number of sites", "Number of sequences"))

how_many_models %>% 
  full_join(hamming) %>% 
  full_join(data_info) %>%
  group_by(ic_type, datatype) %>%
  mutate(stable = ifelse(n_models ==1, 1, 0)) -> data_for_logit


## Perform logistic, yes I know below says logit, it's not. ---
data_for_logit %>%
  nest() %>%
  mutate(logit_fit = map(data, logit_stability)) -> fitted_logit
  
fitted_logit %>%
  mutate(tidied = map(logit_fit, tidyci)) %>%
  select(-data, -logit_fit) %>%
  unnest(cols = tidied) %>%
  filter(term != "(Intercept)") %>%
  select(-statistic, -std.error) %>% 
  rename(coefficient = term, coefficient_p = p.value) %>%
  mutate(fct_coefficient = factor(coefficient, 
                                 levels = coeff_levels,
                                 labels = coeff_labels),
         sig = ifelse(coefficient_p <= p_threshold, "cen", "lo")) %>%
  ungroup() -> logit_coefficients
  
  
fitted_logit %>%
  mutate(aug = map(logit_fit, broom::augment)) %>%
  unnest(cols = aug) %>%
  select(.fitted, stable, logit_fit, data) %>%
  mutate(stable = factor(stable, levels=c(0,1))) %>%
  ungroup()-> logit_resp_pred

# can't get this to map well, booooo loop time
logit_auc <- tibble(ic_type = as.character(),
                     datatype = as.character(),
                     auc = as.numeric())
for (ic in c("AIC", "AICc", "BIC"))
{
  for (dt in c("AA", "NT"))
  {
    logit_resp_pred %>%
      filter(ic_type == ic, datatype == dt) -> this
    
    pROC::roc(this$stable, this$.fitted) -> thisroc
    name <- paste(ic, dt, sep = "-")

    logit_auc %<>%
      bind_rows(
        tribble(~ic_type, ~datatype, ~auc, 
                ic,       dt,        round(thisroc$auc[[1]],2)
        )
      )
  }
}  

logit_coefficients %>%
  ggplot(aes(x = estimate, y = fct_coefficient)) + 
  geom_vline(xintercept = 0, color = "grey40") + 
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
  geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
  facet_grid(ic_type ~ datatype) + 
  scale_fill_manual(values = c("firebrick", "white")) +
  xlim(c(-4,7)) + 
  labs(x = "Effect size ± 95% CI", 
       y = "Fitted model coefficient") +
  geom_text(data = logit_auc, 
            x = -2.75, 
            y = 4.25, 
            size=3,
            aes(label = paste("AUC = ", auc))) +
  theme(legend.position = "none") -> logit_model_plot



## Figure of logistic predictors -------------
data_for_logit %>%
  select(id, datatype, dataset, mean_hamming, mean_nsites, nseq, mean_guidance_score) %>%
  pivot_longer(mean_hamming:mean_guidance_score,
               names_to = "predictor", 
               values_to = "value") %>%
  mutate(predictor = case_when(
    predictor == "mean_hamming" ~ "Mean edit\ndistance",
    predictor == "mean_guidance_score" ~ "Mean GUIDANCE\nscore",
    predictor == "mean_nsites" ~ "Mean number\nof sites",
    predictor == "nseq" ~ "Number of\nsequences")) %>%
  mutate(predictor = fct_relevel(predictor, "Mean GUIDANCE\nscore")) %>%
  ggplot() + 
    aes(x = dataset, y = value, color = dataset) + 
    ggforce::geom_sina(size = 0.1) +
    geom_violin(alpha = 0, color = "black", size = 0.25) +
    facet_grid(predictor~datatype, scales = "free_y") + 
    theme(legend.position = "none",
          strip.text = element_text(size = rel(0.75))) +
    scale_color_viridis_d() + 
    labs(x = "Dataset source", y = "Values of predictor variables") -> logit_pred_violins

## save logit a/b fig --------------------------
logit_grid <- plot_grid(logit_model_plot, logit_pred_violins, labels = "auto", nrow = 2, scale = 0.98)
save_plot(file.path(output_path, "logit_glms.png"), logit_grid, base_height = 10, base_width=7)




## Tukey for SP and TC -------------------------------------
comparison_options <- c("differs-matches", "stable-matches", "stable-differs")
scores_plot_data %>% 
  mutate(group = factor(group, levels=c("matches", "differs", "stable"))) %>%
  group_by(datatype, score_type, ic_type) %>%
  nest() %>%
  mutate(fit = map(data, tukey_sp_tc)) %>%
  unnest(cols = fit) %>%
  clean_tukey() %>%
  ungroup() %>%
  filter(Comparison %in% comparison_options) %>%
  mutate(`Adjusted P-value` = round(`Adjusted P-value`, 3)) -> modeled_scores_table


# MAIN TEXT TABLE, rest SI.
modeled_scores_table %>% 
  filter(ic_type == "AIC") %>%
  select(-ic_type, -`Adjusted P-value`) %>%
  xtable::xtable()
  
  








## Linear no longer used
# 
# lm_nmodels <- function(df)
# {
#   lm(n_models ~ mean_hamming + mean_guidance_score + nseq + mean_nsites, data = df)
# }
# fitme_nmodels %>%
#   group_by(ic_type, datatype) %>%
#   nest() %>%
#   mutate(fit = map(data, lm_nmodels)) -> fitted_lm
# 
# fitted_lm %>%
#   mutate(glanced = map(fit, broom::glance)) %>%
#   unnest(cols = glanced) %>%
#   select(rsquared = adj.r.squared, rsquared_p = p.value, -c(r.squared, sigma, logLik, AIC, BIC, deviance, df.residual, nobs)) %>%
#   ungroup() %>%
#   mutate(rsquared = round(rsquared,2)) -> fitted_lm_rsq
# 
# fitted_lm %>%
#   mutate(tidied = map(fit, tidyci)) %>%
#   unnest(cols = tidied) %>%
#   select(-c(std.error, statistic, data, fit)) %>%
#   rename(coefficient = term, coefficient_p = p.value) %>%
#   filter(coefficient != "(Intercept)") %>%
#   mutate(fct_coefficient = factor(coefficient, 
#                                   levels = coeff_levels,
#                                   labels = coeff_labels),
#          sig = ifelse(coefficient_p <= p_threshold, "cen", "lo")) %>%
#   ungroup() -> fitted_lm_coefficients
# 
# fitted_lm_coefficients %>%
#   ggplot(aes(x = estimate, y = fct_coefficient)) + 
#   geom_vline(xintercept = 0, color = "grey40") + 
#   geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
#   geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
#   scale_fill_manual(values = c("dodgerblue", "white")) +
#   facet_grid(ic_type ~ datatype) + 
#   xlim(c(-4, 7)) + 
#   labs(x = "Coefficient estimate ± 95% CI", 
#        y = "Fitted model coefficient") +
#   geom_text(data = fitted_lm_rsq, 
#             x = 6.3, 
#             y = 7, 
#             size=3,
#             aes(label = paste("R^2 == ", rsquared)), parse=T) +
#   theme(legend.position = "none") -> lm_model_plot
#plot_grid(lm_model_plot, logit_model_plot, nrow=1, labels = "auto", scale=0.95, label_size = 17) -> model_grid
#save_plot(file.path(output_path, "grid_nmodels_modelstability_nosd.png"),model_grid, base_height = 5, base_width=15 )
