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

# Make sub-folders needed by many other scripts
## Order of following lines is a rough match for workflow order
dir.create(file.path("data", "00_raw"), showWarnings = F)
dir.create(file.path("data", "01_standard"), showWarnings = F)
dir.create(file.path("data", "wrtds"), showWarnings = F)
dir.create(file.path("data", "spatial"), showWarnings = F)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
