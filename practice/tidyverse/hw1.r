library (ggplot2)
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

#problem 1
attach(Alfalfa)
mod <- lm (Ht4 ~ Acid)
summary(mod)
anova(mod)


#problem 2
#Create a boxplot of the plant growth, separated by acid 
#amounts. Based on this plot, is the mean height of alfalfa 
#grown in 3.0HCl the same or different from the mean height 
#of alfalfa grown in water? Explain your answer.

ggplot(Alfalfa,aes(x= Acid, y= Ht4)) + geom_boxplot()
#the mean height is different from 3.0HCl and water 

#problem3 
#Use a t test to determine if the mean height of plants 
#grown in 3.0HCl is the same or different from the mean 
#height of plants grown in water. Interperet and explain your results in 1-2 sentences.

mean_w <- mean(Alfalfa$Ht4)
print(mean_w)
t.test(mean_w, Alfalfa$Row)




