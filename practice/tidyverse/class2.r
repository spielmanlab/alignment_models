library(ggplot2)

#command + enter, highlighted text gets run (source)

#comment in R!
PlantGrowth
attach (PlantGrowth)

plants <- unstack(PlantGrowth)
head (plants)
boxplot(plants)

#use t.test
#a
t.test(plants$ctrl, plants$trt1)
#p value is 0.25, control and treatment 1 do not appear to be
#different

#b. treatment 1 vs treatment 2
t.test(plants$trt1, plants$trt2)

#correlation
cars
#cor.test test
cor.test(cars$speed, cars$dist)
plot(cars$speed, cars$dist)

#regression
library(MASS)
head(cabbages)

#linear regression lm() = y var, x var 
#y var is dependent, x var is independent

cab <- lm(VitC ~ Cult + HeadWt, data=cabbages)
summary(cab)
anova(cab)


