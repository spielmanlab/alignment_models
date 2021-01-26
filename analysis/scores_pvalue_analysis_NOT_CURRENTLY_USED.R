
## Modeling the TC and SP scores -----------------------------------------------
models %>%
  filter(num == 50) %>%
  rename(rep50_model = best_model,
         rep50_matrix = best_matrix) %>%
  select(-num) %>%
  right_join(models) %>%
  filter(num!=50) %>%
  # ivrit makes the factors in the right order. anglit fail.
  mutate(same_model_rep50 = ifelse(rep50_model == best_model, "cen", "lo"),
         same_matrix_rep50 = ifelse(rep50_matrix == best_matrix, "cen", "lo")) %>%
  select(-rep50_model, -best_model, -best_matrix) %>%
  #filter(num!=50) %>%
  select(same_model_rep50, same_matrix_rep50, everything())-> same_as_rep50



# What about where ALL are rep50?
same_as_rep50 %>%
  select(-same_matrix_rep50) %>%
  filter(same_model_rep50 == "cen") %>%
  count(same_model_rep50, id, datatype, ic_type, name = "count_model_sameas_rep50") %>%
  filter(count_model_sameas_rep50 == 49) %>%
  inner_join(scores) %>%
  select(-same_model_rep50, -ref_num, -est_num) %>%
  group_by(id, datatype, ic_type) %>%
  summarize(mean_sp = mean(sp), mean_tc = mean(tc))%>%
  pivot_longer(mean_sp:mean_tc,names_to = "score_type", values_to = "mean_score") %>%
  mutate(same_model_rep50 = "allsame")-> mean_scores_all_same

same_as_rep50 %>%
  filter(same_model_rep50 == "cen", 
         same_matrix_rep50 == "cen") %>%
  count(same_model_rep50, id, datatype, ic_type, name = "count_model_sameas_rep50") %>%
  # Need at least THREE observations per group. 
  # THere are 49 comparisons. Need something between 4-46 (since 47, 48, 49)
  filter(between(count_model_sameas_rep50, 3, 46)) %>%
  select(id, datatype, ic_type) %>%
  inner_join(same_as_rep50) %>%
  ungroup() -> rep50_data_for_lm

# Check number observations are >=3. YES - this has 0 rows.
rep50_data_for_lm %>%
  count(id, datatype, ic_type, same_model_rep50) %>%
  filter(n < 3) %>%
  nrow() -> bad_rows
stopifnot(bad_rows == 0)


rep50_data_for_lm %>%
  select(id, datatype) %>% # ic_type) %>%
  distinct() %>%
  tally() # 5222 situations are able to be modeled here.

lm_scores <- function(df)
{
  lm(sp ~ same_model_rep50, data = df) -> sp_fit
  lm(tc ~ same_model_rep50, data = df) -> tc_fit
  
  sp_fit %>%
    broom::glance() %>%
    pull(p.value) -> sp_p
  
  sp_fit %>%
    broom::tidy() %>%
    filter(term == "same_model_rep50lo") %>%
    pull(estimate) -> sp_effectsize
  
  tc_fit %>%
    broom::glance() %>%
    pull(p.value) -> tc_p
  
  tc_fit %>%
    broom::tidy() %>%
    filter(term == "same_model_rep50lo") %>%
    pull(estimate) -> tc_effectsize
  
  ## QUESTION: SHOULD I BONFERRONI THESE P-VALUES?
  # Technically all tests are on a different dataset, but there are 3 ic's per underlying ID, so maybe multiply by 3?
  list("sp_p" = sp_p,
       "tc_p" = tc_p,
       "sp_effectsize" = sp_effectsize,
       "tc_effectsize" = tc_effectsize)
}


## This only works when there are at least TWO models, and at least THREE models per group. Need to wrangle data accordingly.
rep50_data_for_lm %>%
  left_join(
    scores %>% 
      select(-ref_num) %>% 
      rename(num = est_num)
  ) %>%
  group_by(id, dataset, datatype, ic_type) %>%
  #filter(id == "EMGT00050000000018", datatype == "NT", ic_type == "AIC") %>%
  nest() %>%
  mutate(fits = map(data, lm_scores)) %>%
  select(-data) %>%
  # THIS FUNCTION IS AMAZING
  unnest_wider(fits) %>%
  ungroup() -> sp_tc_fits

sp_tc_fits %>%
  ungroup() %>%
  select(-sp_effectsize, -tc_effectsize) %>%
  pivot_longer(sp_p:tc_p, names_to = "score_type", values_to = "pvalue") %>%
  mutate(sig = ifelse(pvalue <= p_threshold, "cen", "lo")) %>%
  count(datatype, dataset, ic_type, score_type, sig) -> scores_pvalues_plotme

scores_pvalues_plotme %>%
  filter(score_type == "sp_p") %>%
  ggplot(aes(x = dataset, y = n, fill = sig)) + 
  geom_col(position = position_dodge(), color = "black", size = 0.3) + 
  facet_grid(ic_type ~datatype)

scores_pvalues_plotme %>%
  filter(score_type == "tc_p") %>%
  ggplot(aes(x = dataset, y = n, fill = sig)) + 
  geom_col(position = position_dodge(), color = "black", size = 0.3) + 
  facet_grid(ic_type ~datatype)

sp_tc_fits %>%
  filter(sp_p <= p_threshold) %>%
  ggplot(aes(x = dataset, y = sp_effectsize, color = dataset)) + 
  ggforce::geom_sina(size = 0.8)+
  facet_grid(ic_type ~datatype) +
  scale_color_brewer(palette = "Set1") +
  stat_summary(color = "black", size=0.3)+
  geom_hline(yintercept=0, size=0.2)+
  labs(x = "Dataset source", 
       y = "Mean SP score difference") +
  theme(legend.position = "none") -> sp_effectsize_sina

sp_tc_fits %>%
  filter(tc_p <= p_threshold) %>%
  ggplot(aes(x = dataset, y = tc_effectsize, color = dataset)) + 
  ggforce::geom_sina(size = 0.8)+
  stat_summary(color = "black", size=0.3)+
  geom_hline(yintercept=0, size=0.2)+  facet_grid(ic_type ~datatype) +
  scale_color_brewer(palette = "Set1") +
  labs(x = "Dataset source", 
       y = "Mean TC score difference") +
  theme(legend.position = "none") -> tc_effectsize_sina

# I need to think more about what it means to plot this as absolute value vs showing the positive and negative effect sizes.
# we have two groups of datasets. An expected trend is: SP scores tend to be HIGHER for groups that have the same model as reference. We expect SP scores will be LOWER, on average, for groups that have the same model as reference. 
# For significant differences, we SORT OF observe this trend but it is very minor.
# The effect sizes shown in these plots correspond to the datasets with a DIFFERENT model. Therefore, negative values suggest their SP score distributions are lower than rep50 matches. On the whole, the means are marginally below 0 in particular for PANDIT (although this is a smaller dataset so caution), for both SP and TC. This suggests that there is a indeed an extremely minor trend that alignments giving different models are significantly more different than alignments giving the same model, but again, the effect is miniscule. Actually, let's model it lol

# 


# Even significant differences are small for SP and mostly small for TC
plot_grid(sp_effectsize_sina, tc_effectsize_sina, nrow=1, labels = "auto", scale = 0.95)



isit0 <- function(df)
{
  # will test against 0
  t.test(df$tc_effectsize)$p.value
}


sp_tc_fits %>%
  filter(tc_p <= p_threshold) %>%
  select(id, datatype, ic_type, dataset, tc_effectsize) %>%
  group_by(datatype, ic_type, dataset) %>%
  nest() %>%
  mutate(hmm = map(data, isit0)) %>%
  unnest(hmm)


