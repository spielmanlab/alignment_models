Alfalfa <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/Alfalfa.csv")
head(Alfalfa)

#background data: This homework uses the Alfalfa data set. 
#This data set contains the height of alfalfa sprouts after four days (Ht4) grown indoors 
#in different acidic environments (Acid). There are three different amounts of acid observed 
#in the data set: none (water), moderate (1.5HCl), and strong (3.0HCl). Each treatment was 
#performed on 5 plants. The data set also contains information on the amount of daylight the
#plants received (Row). This column contains values a through e, where a indicates the row 
#farthest from the window and e indicates the row closest to the window.


#problem 1: We are interested in testing the effects of acidic environment 
#on plant growth. Since there are three different amounts of acidity in the data set,
#and therefore three groups of acid measurements, we will use an analysis of variance
#(ANOVA) test. Conduct an ANOVA test and interpret your results in 1-2 sentences.
#HINT: You will first need to create a linear model object using the lm() function 
#before you can use the anova() function.
Alfalfa
attach(Alfalfa)
mod <- lm (Ht4 ~ Acid)
summary(mod)
