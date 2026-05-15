## ----------------------------------------------- ##
# Upload Standardization Outputs
## ----------------------------------------------- ##
## Purpose:
# Uploads standardized data files to Drive
# If file is in Drive already, defaults to not overwriting (to save computing time)
# If re-upload of one/few files is desired, delete them in the Drive rather than changing the 'update_drive' object
## Because changing that object will make _all_ files overwrite which will be _immensely_ time-consuming

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Export Standard Files to Drive ----
## ---------------------------------- ##

# Should files in Drive be replaced with local files?
update_drive <- FALSE

# Identify local files
(local_std <- dir(path = file.path("data", "01_standard")))

# Export them to the relevant Drive folder
purrr::walk(.x = local_std,
  .f = ~ googledrive::drive_upload(media = file.path("data", "01_standard", .x), overwrite = update_drive,
    path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/11Fmti4d0tIKLkXfcsNJXsbRTbaLZzXYy")))

# End ----
