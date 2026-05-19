## ----------------------------------------------- ##
# Populate Data Inventory - Variables Sheet
## ----------------------------------------------- ##
## Purpose:
# Once the river data are in standard formats, we can populate the "variables" sheet of the data inventory
# This sheet defines:
## 1. Which variables were measured at each river
## 2. Measurement units for each variable
## 3. Minimum Detection Limit (MDL) for each variable
## 4. First and last years of measurement for each variable

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, readxl)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Identify Files Missing in Inventory ----
## ---------------------------------- ##
# We only want to do this operation for files not already defined in the 'variables' sheet

# Load relevant piece of data inventory
invent_v01 <- readxl::read_excel(path = file.path("data", "data-inventory.xlsx"), sheet = "variables")

# Check structure
dplyr::glimpse(invent.var_v01)

# Identify local standard files
(local_std <- dir(path = file.path("data", "01_standard")))

# Remove files already described in variables sheet of data inventory
needed_std <- setdiff(X = (invent.var_v01$standard_filename), y = local_std)

# How many fewer files does that mean we need to process?
message(length(local_std) - length(needed_std), " fewer files in need of extraction")

## ---------------------------------- ##
# Extract Variable Info ----
## ---------------------------------- ##

# Make a list for storing outputs
var_list <- list()

# <`for` loop identifying pre-river, per-variable info here>

# Taken from pre-processing script for master 2026 data, should be perfect with minor adaptations
# dplyr::group_by(variable) %>% 
#     dplyr::summarize(
#       first_year = min(lubridate::year(as.Date(focal_df$date)), na.rm = T),
#       last_year = max(lubridate::year(as.Date(focal_df$date)), na.rm = T),
#       .groups = "drop") %>% 
#     # Also add raw file name
#     dplyr::mutate(raw_filename = focal_file,
#       .before = dplyr::everything())

# Unlist to a dataframe
var_v01 <- purrr::list_rbind(x = var_list)

# Check structure
dplyr::glimpse(var_v01)


## ---------------------------------- ##
# Export ----
## ---------------------------------- ##

# Make one final data object
var_v99 <- var_v01

# Check structure
dplyr::glimpse(var_v99)

# Export locally
write.csv(x = var_v99, na = '', row.names = FALSE,
  file = file.path("data", paste0(Sys.Date(), "_data-inventory-variable-expansion.csv")))

# End ----
