library(ggplot2)
#1. tidy data!

#three rules:
#1. each variable forms a column
#2. each observation forms a row
#each type of observational unit forms a table

#a. is iris tidy data?
iris
head(iris)
#yes! has 5 variables which all correspond to one clumn each
#each row in the data corresponds to one observational unit

#b. tidy?
HairEyeColor

#no, doesn't have corresponding columns for hair color, and eyes
#very messy

#2. selecting rows and columns
#dplyr library
library(tidyverse)
#use filter on setosa
iris.setosa <- filter(iris, Species =="setosa")
#a. filters out just things in just one column!
head(iris.setosa)

#b. pick out species virginica and the sepal length is > 7
filter(iris, Sepal.Length>7)
filter(iris, Species== "virginica")
#didn't let me use a logic operator "$" in filter, why?

#c. any cases in the iris dataset for which ratio of sepal length
#to sepal width exceeds petal l/w? use filter to find out
filter(iris, Sepal.Length/Sepal.Width > Petal.Length/Petal.Width)

#Create a pared-down table which contains only data for species
#setosa and which only has the columns Sepal.Length and 
#Sepal.Width. Store the result in a table called iris.pared.

iris.pared <- select(iris.setosa, Sepal.Length, Sepal.Width)
head(iris.pared)

#3. creating new data, arranging!
#Using the function mutate(), create a new data column that
#holds the ratio of sepal length to sepal width.
#Store the resulting table in a variable called iris.ratio.
sepal.length.to.width = Sepal.Length/Sepal.Width
iris.ratio <- mutate(iris, sepal.length.to.width)
head(iris.ratio)

order <- arrange(iris.ratio, Species, sepal.length.to.width)
head(order)

#4. grouping and summarizing 

#a. caclulate the mean and s.d. of sepal lengths of each species
iris.grouped <- group_by(iris, Species)
head (iris.grouped)
summarize(iris.grouped,
          mean.speal.legnth = mean(Sepal.Length),
          sd.sepal.legnth = sd(Sepal.Length))

#b. use n() 
#function is implemented specifically for each data source
#can only be used w/ summarize(), mutate() and filter()

summarize(iris.grouped, count = n())

#c. calculate percentage of cases w./ sepal length > 5.5
summarize(iris.grouped, percent = sum(Sepal.Length>5.5)/n())


#5. if this was easy!
#don't need to load ggplot again b/c it's apart of tidyverse
#tidyverse is a collection of packages

#a. take iris.ratio and plot sepal length to width ratio for 3 species

ggplot(iris.ratio, aes(x = sepal.length.to.width, fill = Species)) + geom_density(alpha = 0.3)

#b.  plot sepal length to width ratio vs sepal length

ggplot(iris.ratio, aes(y = sepal.length.to.width, x = Sepal.Length, color = Species)) + geom_point()


