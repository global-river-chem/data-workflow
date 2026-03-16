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

# Do you need to re-download?
redownload <- FALSE

# If redownloading is desired...
if(redownload == T){

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
}

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
chem_v01 <- read.csv(file = file.path("data", "preprocess-not-done", "20260105_masterdata_chem.csv"))

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
length(intersect(unique(ref_v02$Stream_Name), unique(chem_v02$Stream_Name)))

# Check structure
dplyr::glimpse(chem_v02)

# Join the ref table
chem_v03 <- chem_v02 %>% 
  dplyr::left_join(y = ref_v02, by = c("LTER", "Stream_Name"))

## ---------------------------------- ##
# Prepare 'Master' Discharge Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
disc_v01 <- read.csv(file = file.path("data", "preprocess-not-done", "20260106_masterdata_discharge.csv"))

# Check structure
dplyr::glimpse(disc_v01)

# Do needed wrangling
disc_v02 <- disc_v01 %>% 
  # Make all missing values true NAs
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
    .fns = ~ ifelse(nchar(.) == 0, yes = NA, no = .))) %>%
  # Fill missing LTER info
  dplyr::mutate(LTER = dplyr::case_when(
    is.na(LTER) & Discharge_File_Name %in% c("AND_GSWSMA_Q", "AND_GSWSMF_Q") ~ "AND",
    is.na(LTER) & Discharge_File_Name == "Ljungan Skallboleforsen_Q" ~ "Sweden",
    is.na(LTER) & Discharge_File_Name %in% c("M764.3A_Q") ~ "UMR",
    is.na(LTER) & Discharge_File_Name %in% c("MD_403241_Q", "MD_405232_Q", "MD_406202_Q",
      "MD_407202_Q", "MD_409025_Q", "MD_425007_Q") ~ "MD",
    is.na(LTER) & Discharge_File_Name %in% c("Site12_Q", "Site15_Q", "Site20_Q") ~ "Krycklan",
    is.na(LTER) & Discharge_File_Name == "UpperJaramillo_Q" ~ "USGS",
    TRUE ~ LTER))

disc_v02 %>% filter(is.na(LTER)) %>% pull(Discharge_File_Name) %>% unique()

# Check structure
dplyr::glimpse(disc_v02)

# End ----
