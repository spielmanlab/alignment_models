
## Functions for modeling ----------------------------------
lm_nmodels <- function(df)
{
  lm(n_models ~ mean_hamming + sd_hamming + nseq + mean_nsites + sd_nsites, data = df)
}

logit_stability <- function(df)
{
  glm(stable ~ mean_hamming + sd_hamming + nseq + mean_nsites+ sd_nsites, data = df, family = "binomial")
}


lm_nmatrices <- function(df)
{
  lm(n_matrices ~ mean_hamming + sd_hamming + nseq + mean_nsites+ sd_nsites, data = df)
}

tidyci <- function(fit)
{
  broom::tidy(fit, conf.int = TRUE) # uses 95 CI
}


build_lm_model <- function(grouped_df, model_or_matrix)
{
  grouped_df %>%
    group_by(ic_type, datatype) %>%
    nest() -> fitme
  
  if (model_or_matrix == "model") fitme %<>% mutate(fit = map(data, lm_nmodels))
  if (model_or_matrix == "matrix") fitme %<>% mutate(fit = map(data, lm_nmatrices))

  
  fitme %>%
    mutate(glanced = map(fit, broom::glance)) %>%
    unnest(cols = glanced) %>%
    select(rsquared = adj.r.squared, rsquared_p = p.value, -c(r.squared, sigma, logLik, AIC, BIC, deviance, df.residual, nobs)) %>%
    ungroup() %>%
    mutate(rsquared = round(rsquared,2)) -> fitted_rsq
  
  fitme %>%
    mutate(tidied = map(fit, tidyci)) %>%
    unnest(cols = tidied) %>%
    select(-c(std.error, statistic, data, fit)) %>%
    rename(coefficient = term, coefficient_p = p.value) %>%
    filter(coefficient != "(Intercept)") %>%
    mutate(fct_coeffcient = factor(coefficient, 
                                   levels = coeff_levels,
                                   labels = coeff_labels),
           sig = ifelse(coefficient_p <= p_threshold, "cen", "lo")) %>%
    ungroup() -> fitted_coefficients
  
  list(fitted_rsq, fitted_coefficients)
}



build_logit_model <- function(grouped_df, model_or_matrix)
{
  
  if (model_or_matrix == "model") grouped_df %<>% mutate(stable = ifelse(n_models ==1, 1, 0)) 
  if (model_or_matrix == "matrix") grouped_df %<>% mutate(stable = ifelse(n_matrices ==1, 1, 0)) 

  grouped_df %>%
    nest() %>%
    mutate(logit_fit = map(data, logit_stability)) -> fitme
  
  fitme %>%
    mutate(tidied = map(logit_fit, tidyci)) %>%
    select(-data, -logit_fit) %>%
    unnest(cols = tidied) %>%
    filter(term != "(Intercept)") %>%
    select(-statistic, -std.error) %>% 
    rename(coefficient = term, coefficient_p = p.value) %>%
    mutate(fct_coeffcient = factor(coefficient, 
                                   levels = coeff_levels,
                                   labels = coeff_labels),
           sig = ifelse(coefficient_p <= p_threshold, "cen", "lo")) %>%
    ungroup() -> logit_coefficients
  
  
  fitme %>%
    mutate(aug = map(logit_fit, broom::augment)) %>%
    unnest(cols = aug) %>%
    select(.fitted, stable, logit_fit, data) %>%
    mutate(stable = factor(stable, levels=c(0,1))) %>%
    ungroup()-> logit_resp_pred
  print(logit_resp_pred)
    
  logit_aic <- compute_logit_auc(logit_resp_pred)
  
  list(logit_aic, logit_coefficients)
}

compute_logit_auc <- function(df)
{
  auc_tibble <- tibble(ic_type = as.character(),
                       datatype = as.character(),
                       auc = as.numeric())
  for (ic in c("AIC", "AICc", "BIC"))
  {
    for (dt in c("AA", "NT"))
    {
      df %>%
        filter(ic_type == ic, datatype == dt) -> this
      
      pROC::roc(this$stable, this$.fitted) -> thisroc
      name <- paste(ic, dt, sep = "-")

      auc_tibble %<>%
        bind_rows(
          tribble(~ic_type, ~datatype, ~auc, 
                  ic,       dt,        round(thisroc$auc[[1]],2)
          )
        )
    }
  }  
  auc_tibble
}


## Actual modeling -------------------------------------

p_threshold <- 0.05
coeff_levels <- rev(c("mean_hamming", "sd_hamming", "mean_nsites", "sd_nsites", "nseq"))
coeff_labels <- rev(c("Mean edit distance", "SD edit distance",  "Mean number of sites", "SD number of sites", "Number of sequences"))
# Prepare model and matrix data for modeling

how_many_models %>% 
  full_join(hamming) %>% 
  full_join(data_info) %>%
  group_by(ic_type, datatype) -> fitme_nmodels

how_many_matrices %>% 
  full_join(hamming) %>% 
  full_join(data_info) %>%
  group_by(ic_type, datatype) -> fitme_nmatrices


# Linear fits: number of models or matrices
nmodel_fitted_results    <- build_lm_model(fitme_nmodels, "model")
nmodel_rsq <- nmodel_fitted_results[[1]]
nmodel_coefficients <- nmodel_fitted_results[[2]]

nmatrices_fitted_results <- build_lm_model(fitme_nmatrices, "matrix")
nmatrix_rsq <- nmatrices_fitted_results[[1]]
nmatrix_coefficients <- nmatrices_fitted_results[[2]]



# Logistic fits: model or matrix stability
stable_models_logit <- build_logit_model(fitme_nmodels, "model")
stable_models_auc <- stable_models_logit[[1]]
stable_models_coefficients <- stable_models_logit[[2]]

stable_matrices_logit <- build_logit_model(fitme_nmatrices, "matrix")
stable_matrices_auc <- stable_matrices_logit[[1]]
stable_matrices_coefficients <- stable_matrices_logit[[2]]

nmodel_coefficients %>%
  ggplot(aes(x = estimate, y = fct_coeffcient)) + 
  geom_vline(xintercept = 0, color = "grey40") + 
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
  geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
  scale_fill_manual(values = c("dodgerblue", "white")) +
  facet_grid(ic_type ~ datatype) + 
  xlim(c(-4, 7)) + 
  labs(x = "Coefficient estimate ± 95% CI", 
       y = "Fitted model coefficient") +
  geom_text(data = nmodel_rsq, 
            x = 6.25, 
            y = 5.1, 
            size=3,
            aes(label = paste("R^2 == ", rsquared)), parse=T) +
  theme(legend.position = "none") -> lm_model_plot



stable_models_coefficients %>%
  ggplot(aes(x = estimate, y = fct_coeffcient)) + 
  geom_vline(xintercept = 0, color = "grey40") + 
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
  geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
  facet_grid(ic_type ~ datatype) + 
  scale_fill_manual(values = c("firebrick", "white")) +
  xlim(c(-5.5, 8)) + 
  labs(x = "Coefficient estimate ± 95% CI", 
       y = "Fitted model coefficient") +
  geom_text(data = stable_models_auc, 
            x = 6.5, 
            y = 5, 
            size=3,
            aes(label = paste("AUC = ", auc))) +
  theme(legend.position = "none") -> logit_model_plot



### SI!!!!! SAME EXACT TRENDS.
nmatrix_coefficients %>%
  mutate(sig = ifelse(coefficient_p <= 0.05, "cen", "lo")) %>% 
  ggplot(aes(x = estimate, y = fct_coeffcient)) + 
  geom_vline(xintercept = 0, color = "grey40") + 
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
  geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
  scale_fill_manual(values = c("dodgerblue", "white")) +
  facet_grid(ic_type ~datatype) + 
  xlim(c(-3, 5)) + 
  labs(x = "Coefficient estimate ± 95% CI", 
       y = "Fitted model coefficient") +
  geom_text(data = nmatrix_rsq, 
            x = 4.5, 
            y = 5.1, 
            size=3,
            aes(label = paste("R^2 == ", rsquared)), parse=T) +
  theme(legend.position = "none") -> lm_matrix_plot



stable_matrices_coefficients %>%
  mutate(sig = ifelse(coefficient_p <= 0.05, "cen", "lo")) %>% 
  ggplot(aes(x = estimate, y = fct_coeffcient)) + 
  geom_vline(xintercept = 0, color = "grey40") + 
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.3, color = "black") +
  geom_point(pch = 21, aes(fill = sig), color = "black", size = 2.5) + 
  scale_fill_manual(values = c("firebrick", "white")) +
  facet_grid(ic_type ~ datatype) + 
  xlim(c(-5.5, 8.5)) + 
  labs(x = "Coefficient estimate ± 95% CI", 
       y = "Fitted model coefficient") +
  geom_text(data = stable_matrices_auc, 
            x = 6.5, 
            y = 5, 
            size=3,
            aes(label = paste("AUC = ", auc))) +
  theme(legend.position = "none") -> logit_matrix_plot

plot_grid(lm_model_plot + ggtitle("Linear regression to predict number of models for a dataset"), logit_model_plot + ggtitle("Logistic regression to predict dataset selected model stability"), nrow=1, labels = "auto", scale=0.95) -> model_grid
save_plot(file.path(output_path, "grid_nmodels_modelstability.pdf"),model_grid, base_height = 6, base_width=15 )

plot_grid(lm_matrix_plot + ggtitle("Linear regression to predict number of matrices for a dataset"), logit_matrix_plot + ggtitle("Logistic regression to predict dataset selected matrix stability"), nrow=1, labels = "auto", scale=0.95) -> matrix_grid
save_plot(file.path("grid_nmatrices_matrixstability.pdf"_,matrix_grid, base_height = 6, base_width=15 )

