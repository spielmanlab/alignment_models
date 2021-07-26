print("Setting up")
source("01_setup.R")

print("Loading and preparing data")
source("02_load_prepare_data.R") 

print("Building regressions")
source("03_build_glms.R")

print("Making main text figures")
source("04_make_figures.R")

print("Rendering SI")
pagedown::chrome_print("supplementary_information.Rmd")

