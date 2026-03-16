## ----------------------------------------------- ##
# Pre-Process ('Split') GlASS Data
## ----------------------------------------------- ##
## Purpose:
# Later workflows work on individual rivers' data.
# GlASS collates many rivers' data so we need to split it apart,
# so that we can make the same assumptions of these inputs as we do for others

# Get set up
source(file = file.path("-setup.r"))
## Including sub-folders only (or mostly only) needed by this script
dir.create(file.path("data", "preprocess-not-done"), showWarnings = F)
dir.create(file.path("data", "preprocess-done"), showWarnings = F)

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse, googledrive)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Download 'Master' Data ----
## ---------------------------------- ##

# Identify master chemistry file
(chem_master <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/1dTENIB5W2ClgW0z-8NbjqARiaGO2_A7W")) %>% 
  dplyr::filter(name == "20260105_masterdata_chem.csv"))

# Download it locally
googledrive::drive_download(file = chem_master$id, overwrite = T,
  path = file.path("data", "chemistry_preprocess-not-done", chem_master$name))

# Identify master discharge file
(q_master <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/1hbkUsTdo4WAEUnlPReOUuXdeeXm92mg-")) %>% 
  dplyr::filter(name == "20260106_masterdata_discharge.csv"))

# Download it locally
googledrive::drive_download(file = q_master$id, overwrite = T,
  path = file.path("data", "discharge_preprocess-not-done", q_master$name))

# Identify reference table
(ref.table <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/0AIPkWhVuXjqFUk9PVA")) %>% 
  dplyr::filter(name == "Site_Reference_Table"))

# Download it locally
googledrive::drive_download(file = ref.table$id, overwrite = T,
  path = file.path("data", "discharge_preprocess-not-done", "site-ref-table.csv"))



## ---------------------------------- ##
# Load 'Master' Chemistry Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
chem_v01 <- read.csv(file = file.path("data", "chemistry_preprocess-not-done", chem_master$name))

# Check structure
dplyr::glimpse(chem_v01)

## ---------------------------------- ##
# Load 'Master' Discharge Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
disc_v01 <- read.csv(file = file.path("data", "discharge_preprocess-not-done", q_master$name))

# Check structure
dplyr::glimpse(disc_v01)

## ---------------------------------- ##
# Check River Overlap ----
## ---------------------------------- ##

intersect(x = chem_v01$Stream_name, y = disc_v01$Stream_Name)



## ---------------------------------- ##
# Preliminary Wrangling ----
## ---------------------------------- ##

# Do any generally-useful wrangling
chem_v02 <- chem_v01 %>% 
  # Drop unwanted column(s)
  dplyr::select(-X, -Site.Stream.Name) %>% 
  # Move variable to a more intuitive spot
  dplyr::relocate(variable, .before = value) %>% 
  # Handle special characters in site names
  dplyr::mutate(
    # Remove some characters
    site = gsub(pattern = " |\\(|\\)|<|>", replacement = "", x = site),
    # Replace others with hyphens
    site = gsub(pattern = "\\/|\\\\|\\.", replacement = "-", x = site)
  ) %>% 
  # Do some renaming
  dplyr::rename(program = LTER,
    date = Sampling.Date)

# Check structure
dplyr::glimpse(chem_v02)

## ---------------------------------- ##
# Split By River & Export ----
## ---------------------------------- ##

# Iterate across 'LTER'
for(focal_program in sort(unique(chem_v02$program))){
  ## focal_program <- "AND"

  # Progress message
  message("Separating ", focal_program, " rivers")

  # Subset
  chem_sub.program <- dplyr::filter(chem_v02, program == focal_program)

  # And iterate across rivers within that
  for(focal_river in sort(unique(chem_sub.program$site))){
    ## focal_river <- "GSLOOK"

    # Subset again
    chem_sub.river <- dplyr::filter(chem_sub.program, site == focal_river)
    
    # Assemble a good filename
    focal_out <- paste0(paste("2022-masterchem", focal_program, focal_river, sep = "_"), ".csv")

    # Export locally
    write.csv(x = chem_sub.river, na = '', row.names = F,
      file = file.path("data", "chemistry_preprocess-done", focal_out))

  } # Close 'river' loop
} # Close 'program' loop

# End ----
