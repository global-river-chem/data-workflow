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

# Make subfolders folders that need chemistry and discharge variants
purrr::walk(.x = paste0(c("chemistry_", "discharge_"), 
    sort(rep(c("preprocess-not-done", "preprocess-done", 
      "raw", "standardized"), times = 2))),
  .f = ~ dir.create(path = file.path("data", .x),
    showWarnings = F))

# Make other needed subfolders
dir.create(file.path("data", "wrtds"), showWarnings = F)
dir.create(file.path("data", "spatial"), showWarnings = F)

# Clear environment + collect garbage
rm(list = ls()); gc()

# End ----
