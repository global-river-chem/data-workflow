## ----------------------------------------------- ##
# Standardize Raw Data
## ----------------------------------------------- ##
## Purpose:
# Accept raw river data and standardize it into the format required by later scripts
# Note this is done on a per-river basis so will create as many standard files as there were raw files
## This is _many_ files so expect the per-river operation to be quick but the total operation to be time-consuming

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Prepare Data Inventory ----
## ---------------------------------- ##

# Read in the inventory
invent_v01 <- read.csv(file = file.path("data", "data-inventory.csv"))

# Check structure
dplyr::glimpse(invent_v01)

## ---------------------------------- ##
# Standardize Raw Data ----
## ---------------------------------- ##

# Identify local raw data
(local_raw <- dir(path = file.path("data", "00_raw")))


# <`for` loop standardizing files via names in data inventory to be built here>


# End ----
