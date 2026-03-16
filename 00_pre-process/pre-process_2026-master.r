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
  path = file.path("data", "preprocess-not-done", chem_master$name))

# Identify master discharge file
(q_master <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/1hbkUsTdo4WAEUnlPReOUuXdeeXm92mg-")) %>% 
  dplyr::filter(name == "20260106_masterdata_discharge.csv"))

# Download it locally
googledrive::drive_download(file = q_master$id, overwrite = T,
  path = file.path("data", "preprocess-not-done", q_master$name))

# Identify reference table
(ref.table <- googledrive::drive_ls(path = googledrive::as_id("https://drive.google.com/drive/u/1/folders/0AIPkWhVuXjqFUk9PVA")) %>% 
  dplyr::filter(name == "Site_Reference_Table"))

# Download it locally
googledrive::drive_download(file = ref.table$id, overwrite = T,
  path = file.path("data", "preprocess-not-done", "2026-master_site-ref-table.csv"))

## ---------------------------------- ##
# Prepare Reference Table ----
## ---------------------------------- ##

# Read in the reference table used for in 2026 (and earlier)
ref_v01 <- read.csv(file.path("data", "preprocess-not-done", "2026-master_site-ref-table.csv"))

# Check structure
dplyr::glimpse(ref_v01)

# Do some needed prep stuff
ref_v02 <- ref_v01 %>% 
  # Pare down to only crucial columns
  dplyr::select(LTER, Discharge_File_Name, Stream_Name) %>%
  # Drop non-unique rows
  dplyr::distinct()

# Check structure
dplyr::glimpse(ref_v02)

## ---------------------------------- ##
# Prepare 'Master' Chemistry Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
chem_v01 <- read.csv(file = file.path("data", "preprocess-not-done", chem_master$name))

# Check structure
dplyr::glimpse(chem_v01)

# How many rivers are found in both the chem data and the ref table?
length(intersect(unique(ref_v02$Stream_Name), unique(chem_v01$Stream_Name)))

# Which rivers are found in only one but not the other?
supportR::diff_check(old = unique(ref_v02$Stream_Name), new = unique(chem_v01$Stream_Name))

# Do needed wrangling
chem_v02 <- chem_v01 %>% 
  # Fix any malformed stream names that aren't found in both the chem data and the ref table
  dplyr::mutate(Stream_Name = dplyr::case_when(
    TRUE ~ Stream_Name))

# Did that fix some issues?
message(length(intersect(unique(ref_v01$Stream_Name), unique(chem_v02$Stream_Name))) - length(intersect(unique(ref_v01$Stream_Name), unique(chem_v01$Stream_Name))), " new rivers matched to ref table")

# Check structure
dplyr::glimpse(chem_v02)

# Join the ref table
chem_v03 <- chem_v02 %>% 
  dplyr::left_join(y = ref_v02, by = c("Stream_Name"))

## ---------------------------------- ##
# Prepare 'Master' Discharge Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
disc_v01 <- read.csv(file = file.path("data", "preprocess-not-done", q_master$name))

# Check structure
dplyr::glimpse(disc_v01)

# End ----
