library(tidyverse)

#problem 1. the dataset WorldPhones built into R contains the 
#number of telephones (in thousands) in various regions of the
#world for the years 1951 and 1956-1961. You can run ?WorldPhones 
#to learn more about this data set.

WorldPhones
#worldphones isn't tidy, it should be organized into columns 
#w/ a year, country and number, not rows w/ continents
#no structured table

ToothGrowth
#toothgrowth is tidy data, each row is organized, each variable forms a column,
#each observational unit forms a table

#problem2 
MedGPA <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/MedGPA.csv")
head(MedGPA)

#mean gpa and mean mcat scores
mean(MedGPA$GPA)
mean(MedGPA$MCAT)

#problem3

min(MedGPA$Apps)

#problem 4: graph acceptance over apps
ggplot(MedGPA, aes(y= Apps, x = Acceptance, col = Sex)) + geom_jitter()
