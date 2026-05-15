## ----------------------------------------------- ##
# Download Necessary Standardization Inputs
## ----------------------------------------------- ##
## Purpose:
# The standardization workflow depends on (1) the data inventory, and (2) raw files to standardize
# All relevant inputs are stored in the Drive so this script downloads those algorithmically

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Download the Data Inventory ----
## ---------------------------------- ##

# Identify file in Drive
(inv_drive <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/0AIPkWhVuXjqFUk9PVA")) %>% 
  dplyr::filter(name == "data-inventory"))

# Download it locally
googledrive::drive_download(file = inv_drive$id, overwrite = TRUE, 
  path = file.path("data", paste0(inv_drive$name, ".csv")))

# Read in the inventory
invent_v01 <- read.csv(file = file.path("data", "data-inventory.csv"))

# Check structure
dplyr::glimpse(invent_v01)

## ---------------------------------- ##
# Download Raw Data ----
## ---------------------------------- ##
# Note only raw data with inventory columns for standardization are downloaded
# Those columns include:
## TBA








# End ----
