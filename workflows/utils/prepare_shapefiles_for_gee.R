#' Prepare Shapefiles for GEE Upload
#'
#' This script:
#' 1. Normalizes site names (lowercase, underscores, no special chars)
#' 2. Reprojects all shapefiles to WGS84 (EPSG:4326)
#' 3. Zips each shapefile for GEE upload
#'
#' Run this on any new shapefiles before uploading to GEE.

library(sf)
library(stringi)
library(zip)

# ---- Configuration ----
# Update these paths as needed
INPUT_DIR <- "~/Downloads/silica-shapefiles/artisanal-shapefiles-2"
OUTPUT_DIR <- "~/Downloads/silica-shapefiles/gee-ready"

# ---- Name Normalization ----
normalize_site_name <- function(name) {
  if (is.na(name) || is.null(name)) return(name)

  normalized <- name

  # Normalize unicode characters (ä→a, é→e, ö→o, etc.)
  normalized <- stringi::stri_trans_general(normalized, "Latin-ASCII")

  # Lowercase
  normalized <- tolower(normalized)

  # Replace spaces, hyphens, dots with underscores
  normalized <- gsub("[[:space:]\\-\\.]+", "_", normalized)

  # Remove parentheses but keep content
  normalized <- gsub("[()]", "_", normalized)

  # Remove other special characters
  normalized <- gsub("[,;:'\"!@#$%^&*+=<>?/\\\\|`~\\[\\]{}]", "", normalized)

  # Collapse multiple underscores
  normalized <- gsub("_+", "_", normalized)

  # Strip leading/trailing underscores
  normalized <- gsub("^_|_$", "", normalized)

  return(normalized)
}

# ---- Main Processing Function ----
prepare_shapefile <- function(shp_path, output_dir) {

  # Get original name
  original_name <- tools::file_path_sans_ext(basename(shp_path))
  normalized_name <- normalize_site_name(original_name)

  message(sprintf("Processing: %s -> %s", original_name, normalized_name))

  tryCatch({
    # Read shapefile
    shp <- st_read(shp_path, quiet = TRUE)

    # Check and reproject to WGS84 if needed
    current_crs <- st_crs(shp)

    if (is.na(current_crs)) {
      warning(sprintf("  %s: No CRS defined, assuming WGS84", normalized_name))
      st_crs(shp) <- 4326
    } else if (current_crs$epsg != 4326 || is.na(current_crs$epsg)) {
      message(sprintf("  Reprojecting from %s to WGS84",
                      ifelse(is.na(current_crs$epsg), "unknown CRS", current_crs$epsg)))
      shp <- st_transform(shp, 4326)
    }

    # Validate geometry
    if (!all(st_is_valid(shp))) {
      message("  Fixing invalid geometries")
      shp <- st_make_valid(shp)
    }

    # Create output directory for this shapefile
    shp_output_dir <- file.path(output_dir, "shapefiles", normalized_name)
    dir.create(shp_output_dir, recursive = TRUE, showWarnings = FALSE)

    # Write reprojected shapefile
    output_shp <- file.path(shp_output_dir, paste0(normalized_name, ".shp"))
    st_write(shp, output_shp, quiet = TRUE, delete_layer = TRUE)

    # Create zip file
    zip_dir <- file.path(output_dir, "zipped")
    dir.create(zip_dir, recursive = TRUE, showWarnings = FALSE)
    zip_path <- file.path(zip_dir, paste0(normalized_name, ".zip"))

    # Get all shapefile components
    shp_files <- list.files(shp_output_dir, full.names = TRUE)

    # Create zip
    zip::zip(zip_path, files = shp_files, mode = "cherry-pick")

    return(list(
      success = TRUE,
      original = original_name,
      normalized = normalized_name,
      reprojected = !is.na(current_crs) && (is.na(current_crs$epsg) || current_crs$epsg != 4326)
    ))

  }, error = function(e) {
    warning(sprintf("  ERROR processing %s: %s", original_name, e$message))
    return(list(
      success = FALSE,
      original = original_name,
      normalized = normalized_name,
      error = e$message
    ))
  })
}

# ---- Run Processing ----
process_all_shapefiles <- function(input_dir, output_dir) {

  # Expand paths
  input_dir <- path.expand(input_dir)
  output_dir <- path.expand(output_dir)

  # Create output directory
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  # Find all shapefiles
  shp_files <- list.files(input_dir, pattern = "\\.shp$", full.names = TRUE)
  message(sprintf("Found %d shapefiles to process\n", length(shp_files)))

  # Process each shapefile
  results <- lapply(shp_files, function(shp) {
    prepare_shapefile(shp, output_dir)
  })

  # Summary
  successes <- sum(sapply(results, function(x) x$success))
  failures <- sum(sapply(results, function(x) !x$success))
  reprojected <- sum(sapply(results, function(x) x$success && isTRUE(x$reprojected)))

  message(sprintf("\n========================================"))
  message(sprintf("Processing Complete!"))
  message(sprintf("  Successful: %d", successes))
  message(sprintf("  Reprojected: %d", reprojected))
  message(sprintf("  Failed: %d", failures))
  message(sprintf("\nOutput zips in: %s/zipped/", output_dir))
  message(sprintf("Ready for GEE upload!"))

  # Return results for inspection
  invisible(results)
}

# ---- Execute ----
if (!interactive()) {
  results <- process_all_shapefiles(INPUT_DIR, OUTPUT_DIR)
}
