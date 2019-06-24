library(ggplot2)
#1. Plotting the iris data set
iris
attach(iris)
dataset <- iris
theme_set(theme_bw(base_size=12))
#problem1 
#a
ggplot (dataset, aes(x=Sepal.Length, y=Petal.Length, color=Species)) + geom_point()
#b
ggplot(dataset, aes(x=Sepal.Length, y=Petal.Length, color=Species)) + geom_point() + facet_wrap(~Species)
#c
ggplot(dataset, aes(x=Species, y=Sepal.Length)) + geom_boxplot() 

#2. Plotting tree-growth data

sitka <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/sitka.csv")
head(sitka)

ggplot(sitka, aes(x=Time, y=size, group=tree)) + geom_line() + facet_wrap(~treat)
