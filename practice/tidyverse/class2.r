#comment in R!
PlantGrowth
attach (PlantGrowth)

plants <- unstack(PlantGrowth)
head (plants)
boxplot(plants)