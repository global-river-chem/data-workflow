## ----------------------------------------------- ##
# Populate Data Inventory - Variables Sheet
## ----------------------------------------------- ##
## Purpose:
# Once the river data are in standard formats, we can populate the "variables" sheet of the data inventory
# This sheet defines:
## 1. Which variables were measured at each river
## 2. Measurement units for each variable
## 3. First and last years of measurement for each variable
## 4. Duration of measurement for each variable

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
invent.var_v01 <- readxl::read_excel(path = file.path("data", "data-inventory.xlsx"), sheet = "variables")

# Check structure
dplyr::glimpse(invent.var_v01)

# Identify local standard files
local_std <- dir(path = file.path("data", "01_standard"))

# Remove files already described in variables sheet of data inventory
(needed_std <- setdiff(x = local_std, y = invent.var_v01$standard_filename))

# How many fewer files does that mean we need to process?
message(length(local_std) - length(needed_std), " fewer files in need of extraction")

## ---------------------------------- ##
# Extract Variable Info ----
## ---------------------------------- ##

# Make a list for storing outputs
var_list <- list()

# Loop across rivers
for(focal_river in needed_std){
  # focal_river <- "australian-govt_australia_barwon_site-01.csv"

  # Progress message
  message("Extracting variable info from ", focal_river)

  # Read in the data file
  river_data <- read.csv(file = file.path("data", "01_standard", focal_river))

  # Extract needed info in format matching 'variables' sheet of data inventory
  var_list[[focal_river]] <- river_data %>% 
    dplyr::group_by(variable, unit) %>% 
    dplyr::summarize(
      first_year = min(lubridate::year(as.Date(river_data$date)), na.rm = T),
      last_year = max(lubridate::year(as.Date(river_data$date)), na.rm = T),
      .groups = "drop") %>% 
    dplyr::mutate(standard_filename = focal_river,
      duration = last_year - first_year,
      placeholder01 = NA,
      placeholder02 = NA) %>% 
    dplyr::select(standard_filename, variable, placeholder01, unit, placeholder02, first_year, last_year, duration)

}

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
