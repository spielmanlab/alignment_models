library(tidyverse)
#1. msleep dataset

msleep
head(msleep)
#a. 
totalsleep <- msleep$sleep_total + msleep$awake
totalsleep
#b. make a list of species in msleep, in alphabetical order

msleep %>% filter(conservation == "domesticated") %>%
  select(name) %>% arrange(name)

#use the pipe function a lot in tidy data

#c. tally how many spvore are awake for 18 hours using tally()

msleep %>% filter(awake >=18) %>% group_by(vore) %>% tally()
#piped this ALL into tally function


