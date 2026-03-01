## ----------------------------------------------- ##
# Get Set Up
## ----------------------------------------------- ##
## Purpose:
# Centralize setup operations used by many scripts for ease of access

## ---------------------------------- ##
# Make Needed Folders ----
## ---------------------------------- ##

# Create 'data' folder & sub-folders
dir.create(path = file.path("data", "preprocess_undone"),
  showWarnings = F, recursive = T)
dir.create(path = file.path("data", "preprocess_done"), showWarnings = F)
dir.create(path = file.path("data", "raw"), showWarnings = F)
dir.create(path = file.path("data", "standardized"), showWarnings = F)
dir.create(path = file.path("data", "wrtds"), showWarnings = F)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
