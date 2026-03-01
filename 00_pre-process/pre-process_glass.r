## ----------------------------------------------- ##
# Pre-Process GlASS Data
## ----------------------------------------------- ##
## Purpose:
# Later workflows work on individual rivers' data.
# GlASS collates many rivers' data so we need to split it apart,
# so that we can make the same assumptions of these inputs as we do for others

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Download Master Files ----
## ---------------------------------- ##






# End ----
