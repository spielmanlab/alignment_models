library(ggplot2)
#1 bar plots
bacteria <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/bacteria.csv")
head(bacteria)

#a. make a bar plot that shows the absolute number of cases with
#or without the bacterium, stacked on top
#of each other

data <- bacteria
ggplot(data, aes(x = treatment, fill = presence)) + geom_bar()

#b. modify plot so bars representing absolute number of cases
#with or without the bacterium are shown side by side
 
#position is usually a string, used for overlapping points
ggplot(data, aes(x = treatment, fill = presence)) + geom_bar(position = 'dodge')

#c. modify the plot so bars represent rellative number of cases
#with or without the bacterium, what position option?

ggplot(data, aes(x= treatment, fill = presence)) + geom_bar(position = 'fill')

#2. histograms and density

#a. make a histogram of sepal lengths w/ iris data set
iris
ggplot(iris, aes(x = Sepal.Length)) + geom_histogram()
#different bin widths
#bin (class interval) - way of sorting data in a histogram
#1
ggplot(iris, aes(x = Sepal.Length)) + geom_histogram(binwidth = .5)
#2
ggplot(iris, aes(x = Sepal.Length)) + geom_histogram(binwidth = .03)
#smaller numbers = thinner, larger = wider

#b. use geom_density, fill area under the curves by species identity
ggplot(iris, aes(x=Sepal.Length, fill = Species)) + geom_density()

#make area transparent, using the alpha function
ggplot(iris, aes(x=Sepal.Length, fill = Species)) + geom_density(alpha=0.5)

#lower numbers = more transparent, higher numbers = more opaque

#3. Scales
#movies was removed, so i got it from a differnt source
movies <- read.table("hosturl/movies.tab", sep="\t", header=TRUE, quote="", comment="")
#Reference: http://had.co.nz/data/movies/

#^ doesn't work nevermind

