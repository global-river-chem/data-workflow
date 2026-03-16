## ----------------------------------------------- ##
# Get Set Up
## ----------------------------------------------- ##
## Purpose:
# Centralize setup operations used by many scripts for ease of access

## ---------------------------------- ##
# Make Needed 'Data' Folders ----
## ---------------------------------- ##

# Make relevant top-level folder
dir.create(file.path("data"), showWarnings = F)

# Make sub-folders needed by many/most other scripts
dir.create(file.path("data", "raw"), showWarnings = F)
dir.create(file.path("data", "standardized"), showWarnings = F)
dir.create(file.path("data", "wrtds"), showWarnings = F)
dir.create(file.path("data", "spatial"), showWarnings = F)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
