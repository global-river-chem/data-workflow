## ----------------------------------------------- ##
# Pre-Process ('Split') GlASS Data
## ----------------------------------------------- ##
## Purpose:
# Later workflows work on individual rivers' data.
# GlASS collates many rivers' data so we need to split it apart,
# so that we can make the same assumptions of these inputs as we do for others

# Get set up
source(file = file.path("-setup.r"))

# Load libraries
## install.packages("librarian")
librarian::shelf(tidyverse)

# Clear environment + collect garbage
rm(list = ls()); gc()

## ---------------------------------- ##
# Load 'Master' Chemistry Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
chem_v01 <- read.csv(file = file.path("data", "chemistry_preprocess-not-done", "20221030_masterdata_chem_V2.csv"))

# Check structure
dplyr::glimpse(chem_v01)

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
