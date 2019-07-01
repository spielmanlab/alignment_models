Cars93 <- read.csv("http://wilkelab.org/classes/SDS348/data_sets/Cars93.csv")
head(Cars93)

#background data: This homework uses the Cars93 data set.
#Each observation in the data frame contains information on
#passenger cars from 1993. This is a big data frame with 27 
#columns. We are interested in the information on 
#manufacturer(Manufacturer), car model (Model), type of 
#car (Type), midrange price in $1000 (Price), 
#maximum horsepower (Horsepower), city MPG (miles per US gallon,
#MPG.city), highway MPG (MPG.highway), and fuel tank capacity 
#in gallons (Fuel.tank.capacity).

#problem 1: Use ggplot2 to create a scatter plot of the
#fuel tank capacity versus the car prices. In the same plot,
#fit a curve to these data using geom_smooth(). In one sentence,
#what broad trend do you observe in fuel tank capacity for 
#different car prices? HINT: Plot fuel tank capacity on the 
#y-axis and price on the x-axis.


