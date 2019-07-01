library(ggplot2)
iris 
head(iris)

ggplot(iris, aes(y=Sepal.Length, x=Petal.Length, color=Species)) + geom_point() 

#ugly histogram
ggplot(iris, aes(x=Petal.Length, color=Species)) + geom_histogram()

#barplot
ggplot(iris, aes(x = Sepal.Length, fill = Species )) + geom_bar()

