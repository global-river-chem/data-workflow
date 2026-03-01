## ----------------------------------------------- ##
# Google Drive Interactions
## ----------------------------------------------- ##
## Purpose:
# Download all 'raw' files locally

## Access note:
# To run this script, you need to have two things:
## (1) Access to the relevant Shared Drive
## (2) Authenticated with the 'googledrive' R package
### For a tutorial on this latter point, see here:
### https://lter.github.io/scicomp/tutorial_googledrive-pkg.html

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Clear environment + collect garbage
rm(list = ls()); gc()

# Identify relevant Drive links
chem_url <- googledrive::as_id("https://drive.google.com/drive/u/1/folders/1da8AkSvforPehp-gPJsmA7-pPAJ913mz")
q_url <- googledrive::as_id("https://drive.google.com/drive/u/1/folders/1mw0rYbqpMO4VIXfTH5Ry9USzlR4tbvfb")

## ---------------------------------- ##
# Separate 'Raw' from 'Needs Pre-Processing' ----
## ---------------------------------- ##
# 'raw' files can go straight into the standardization workflow
# 'pre-process' files must be...pre-processed

# Manually identify files that need pre-processing
## Assumes (hopes) fewer in this category
bad_files <- c("20221030_masterdata_disc_V2.csv")

# Identify all chemistry files
chem_files <- googledrive::drive_ls(path = chem_url, pattern = ".csv")

# What's in that?
sort(chem_files$name)

# Identify all discharge files
q_files <- googledrive::drive_ls(path = q_url, pattern = ".csv")

# What's in that?
sort(q_files$name)

## ---------------------------------- ##
# Download Files for Pre-Processing ----
## ---------------------------------- ##

# Do so conditionally, only if there are 'bad' files
if(length(bad_files) != 0){

  # Subset both chem & Q to only those files
  chem_bad <- dplyr::filter(chem_files, name %in% bad_files)
  q_bad <- dplyr::filter(q_files, name %in% bad_files)

  # Download 'em to the relevant place
  ## Chemistry
  purrr::walk2(.x = chem_bad$id, .y = chem_bad$name,
    .f = ~ googledrive::drive_download(file = .x, overwrite = T,
      path = file.path("data", "chemistry_preprocess-not-done", .y)))
  ## Discharge (Q)
  purrr::walk2(.x = q_bad$id, .y = q_bad$name,
    .f = ~ googledrive::drive_download(file = .x, overwrite = T,
      path = file.path("data", "discharge_preprocess-not-done", .y)))

# Message if there are no such files
} else { message("No 'bad files' identified") }

## ---------------------------------- ##
# Download Raw Files ----
## ---------------------------------- ##
## !!!WARNING!!!
# This script downloads _all_ files by default
# Overwriting local copies and not checking what you have locally
# Run with care as this is a time-consuming approach to this

# Remove 'bad' files from chem & Q
chem_raw <- dplyr::filter(chem_files, !name %in% bad_files)
q_raw <- dplyr::filter(q_files, !name %in% bad_files)

# Download 'raw' chemistry files
purrr::walk2(.x = chem_raw$id, .y = chem_raw$name,
  .f = ~ googledrive::drive_download(file = .x, overwrite = T,
    path = file.path("data", "chemistry_raw", .y)))

# Download 'raw' discharge (Q) files
purrr::walk2(.x = q_raw$id, .y = q_raw$name,
  .f = ~ googledrive::drive_download(file = .x, overwrite = T,
    path = file.path("data", "discharge_raw", .y)))

# End ----
