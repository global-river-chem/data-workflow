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
# Prepare 'Master' Discharge Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
disc_v01 <- read.csv(file = file.path("data", "preprocess-not-done", "20260106_masterdata_discharge.csv"))

# Check structure
dplyr::glimpse(disc_v01)

# Do needed wrangling
disc_v02 <- disc_v01 %>% 
  # Remove misleadlingly named value
  dplyr::select(-Stream_Name) %>% 
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
    TRUE ~ LTER)) %>% 
  # Standardize column names/order with chemistry data
  dplyr::rename(date = Date,
    value = Qcms) %>%
  dplyr::relocate(date, value, 
    .after = dplyr::everything()) %>% 
  dplyr::mutate(variable = "discharge",
    units = "cms",
    .before = value)

# How does that overlap with the ref table values?
length(intersect(unique(ref_v02$Discharge_File_Name), unique(disc_v02$Discharge_File_Name)))
supportR::diff_check(old = unique(ref_v02$Discharge_File_Name), new = unique(disc_v02$Discharge_File_Name))

# Check structure
dplyr::glimpse(disc_v02)

# Join the ref table
disc_v03 <- disc_v02 %>% 
  dplyr::mutate(Stream_Name = ref_v02$Stream_Name[match(.$Discharge_File_Name, ref_v02$Discharge_File_Name)])

# Check structure
dplyr::glimpse(disc_v03)

# What discharge data still lacks the more generic 'Stream_Name'?
## Check the ref table and resolve as needed
disc_v03 %>% 
  dplyr::filter(is.na(Stream_Name) | nchar(Stream_Name) == 0) %>% 
  dplyr::pull(Discharge_File_Name) %>% unique()

## ---------------------------------- ##
# Prepare 'Master' Chemistry Data ----
## ---------------------------------- ##

# Read in the old 'master' chem data
chem_v01 <- read.csv(file = file.path("data", "preprocess-not-done", "20260105_masterdata_chem.csv"))

# Check structure
dplyr::glimpse(chem_v01)

# Do needed wrangling
chem_v02 <- chem_v01 %>% 
  # Make all missing values true NAs
  dplyr::mutate(dplyr::across(.cols = dplyr::everything(),
    .fns = ~ ifelse(nchar(.) == 0, yes = NA, no = .))) %>% 
  # Fix any malformed stream names that aren't found in both the chem data and the ref table
  dplyr::mutate(Stream_Name = dplyr::case_when(
    TRUE ~ Stream_Name))

# Did that fix some issues?
length(intersect(unique(ref_v02$Stream_Name), unique(chem_v02$Stream_Name)))

# Check structure
dplyr::glimpse(chem_v02)

# Join the ref table
chem_v03 <- chem_v02 %>% 
  dplyr::mutate(Discharge_File_Name = ref_v02$Discharge_File_Name[match(.$Stream_Name, ref_v02$Stream_Name)])

# Check structure
dplyr::glimpse(chem_v03)

# What chemistry data still lacks the more specific 'Discharge_File_Name'?
## Check the ref table and resolve as needed
chem_v03 %>% 
  dplyr::filter(Stream_Name %in% dplyr::filter(.data = ref_v02, !is.na(Discharge_File_Name) & 
    nchar(Discharge_File_Name) != 0)$Stream_Name) %>% 
  dplyr::filter(is.na(Discharge_File_Name) | nchar(Discharge_File_Name) == 0) %>% 
  dplyr::pull(Stream_Name) %>% unique()

## ---------------------------------- ##
# Separate Each River ----
## ---------------------------------- ##
# We want one data file per river
## Including both chemistry and discharge where both are available

# Get all chem and discharge river names separate
chem_names <- chem_v03 %>% 
  dplyr::select(LTER, Stream_Name, Discharge_File_Name) %>% 
  dplyr::distinct()
disc_names <- disc_v03 %>% 
  dplyr::select(LTER, Stream_Name, Discharge_File_Name) %>% 
  dplyr::distinct()

# List for storing inventory outputs
inventory_out <- list()

# Loop across rows in the reference table
for(k in 1:nrow(ref_v01)){
  ## k <- 2

  # Grab that row of the ref table
  focal_ref <- ref_v01[k, ]

  # Progress message
  message("Processing river ", k, ": '", focal_ref$Stream_Name, "'")

  # Assemble part of the inventory info
  focal_invent <- data.frame(
    "research_network" = focal_ref$LTER,
    "country" = NA,
    "state" = NA,
    "river_name" = focal_ref$Stream_Name, 
    "latitude_dd" = focal_ref$Latitude,
    "longitude_dd" = focal_ref$Longitude,
    "drainage.area_km2" = focal_ref$drainSqKm)

  # If it's found in both data files...
  if(focal_ref$Stream_Name %in% chem_names$Stream_Name & 
      focal_ref$Discharge_File_Name %in% disc_names$Discharge_File_Name){
    
    # Rip it out of both
    focal_chem <- dplyr::filter(chem_v03, Stream_Name == focal_ref$Stream_Name)
    focal_disc <- dplyr::filter(disc_v03, Discharge_File_Name == focal_ref$Discharge_File_Name)

    # Do a quick fix if needed for discharge units
    if(focal_ref$Units != unique(focal_disc$units)
        & !is.na(focal_ref$Units) & nchar(focal_ref$Units) != 0){ focal_disc$units <- focal_ref$Units }

    # Join both
    focal_out <- dplyr::bind_rows(focal_chem, focal_disc)

    # Assemble a nice file name
    focal_name <- paste0("master2026_river-", k, "_", focal_ref$LTER, "_", focal_ref$Stream_Name, ".csv")

    # Export this locally
    write.csv(x = focal_out, na = "", row.names = F,
      file = file.path("data", "preprocess-done", focal_name))

    # If it only has chemistry...
  } else if(focal_ref$Stream_Name %in% chem_names$Stream_Name & 
      !focal_ref$Discharge_File_Name %in% disc_names$SDischarge_File_Name) {

    # Rip it out of chemistry
    focal_chem <- dplyr::filter(chem_v03, Stream_Name == focal_ref$Stream_Name)
    focal_disc <- NULL

    # Join both
    focal_out <- dplyr::bind_rows(focal_chem, focal_disc)

    # Assemble a nice file name
    focal_name <- paste0("master2026_river-", k, "_chem-only_", focal_ref$LTER, "_", focal_ref$Stream_Name, ".csv")

    # Export this locally
    write.csv(x = focal_out, na = "", row.names = F,
      file = file.path("data", "preprocess-done", focal_name))
        
    # If it only has discharge...
  } else if(!focal_ref$Stream_Name %in% chem_names$Stream_Name & 
      focal_ref$Discharge_File_Name %in% disc_names$SDischarge_File_Name) {

    # Rip it out of discharge
    focal_chem <- NULL
    focal_disc <- dplyr::filter(disc_v03, Discharge_File_Name == focal_ref$Discharge_File_Name)

    # Do a quick fix if needed for discharge units
    if(focal_ref$Units != unique(focal_disc$units)
        & !is.na(focal_ref$Units) & nchar(focal_ref$Units) != 0){ focal_disc$units <- focal_ref$Units }
    
    # Join both
    focal_out <- dplyr::bind_rows(focal_chem, focal_disc)

    # Assemble a nice file name
    focal_name <- paste0("master2026_river-", k, "_disc-only_", focal_ref$LTER, "_", focal_ref$Stream_Name, ".csv")

    # Export this locally
    write.csv(x = focal_out, na = "", row.names = F,
      file = file.path("data", "preprocess-done", focal_name)) 
    
  } # Close last conditional

  # Finish prepping inventory info and add to list
  if(is.null(focal_out) != TRUE){
    inventory_out[[paste0("ref-table-", k)]] <- focal_invent %>% 
      # "raw" file name (raw from the perspective of the 'actual' workflow that starts after this script)
      dplyr::mutate(raw_filename = focal_name, .before = dplyr::everything()) %>% 
      # Does the data have chemistry and discharge or just one?
      dplyr::mutate(incl_discharge = ifelse("chem_only" %in% focal_name != T, yes = "yes", no = "no"),
        incl_chemicals = ifelse("disc_only" %in% focal_name != T, yes = "yes", no = "no"),
        .after = river_name) %>% 
      # Which chemicals were included?
      dplyr::mutate(measured_chemicals = ifelse(incl_chemicals != "no", 
        yes = paste0(sort(setdiff(focal_out$variable, "discharge")), collapse = "; "),
        no = NA), .after = incl_chemicals) %>% 
      # What are the first and last years?
      dplyr::mutate(first_year = min(lubridate::year(as.Date(focal_out$date)), na.rm = T),
        last_year = max(lubridate::year(as.Date(focal_out$date)), na.rm = T),
        .after = measured_chemicals)
  }

  # Re-set the 'focal out' object
  focal_out <- NULL
  
} # Close loop

# Unlist the data inventory
ref_inventory <- purrr::list_rbind(x = inventory_out)

# Check that out
dplyr::glimpse(ref_inventory)

# Export locally
write.csv(x = ref_inventory, na = '', row.names = F,
  file = file.path("data", "master2026_ref-table-inventory.csv"))

# End ----
