## ----------------------------------------------- ##
# Get Set Up
## ----------------------------------------------- ##
## Purpose:
# Centralize setup operations used by many pre-processing scripts for ease of access

## ---------------------------------- ##
# Make Needed 'Data' Folders ----
## ---------------------------------- ##

# Make relevant top-level folder
dir.create(file.path("data"), showWarnings = F)

# Make necessary sub-folders
dir.create(file.path("data", "preprocess-not-done"), showWarnings = F)
dir.create(file.path("data", "preprocess-done"), showWarnings = F)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
