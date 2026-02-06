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

# ---- GEE Upload Functions ----

#' Check if CLI tools are installed
check_cli_tools <- function() {
  gsutil_ok <- system("which gsutil", ignore.stdout = TRUE, ignore.stderr = TRUE) == 0
  ee_ok <- system("which earthengine", ignore.stdout = TRUE, ignore.stderr = TRUE) == 0

  if (!gsutil_ok || !ee_ok) {
    message("\n!! Missing CLI tools. One-time setup required:")
    if (!gsutil_ok) {
      message("   gsutil: Install Google Cloud SDK")
      message("   https://cloud.google.com/sdk/docs/install")
    }
    if (!ee_ok) {
      message("   earthengine: Run 'pip install earthengine-api'")
    }
    message("\nAfter installing, authenticate:")
    message("   gcloud auth login")
    message("   earthengine authenticate")
    message("   earthengine set_project silica-synthesis")
    return(FALSE)
  }
  return(TRUE)
}

#' Upload zipped shapefiles to Google Cloud Storage
upload_to_gcs <- function(zip_dir, bucket = "gs://silica-synthesis-shapefiles") {
  if (!check_cli_tools()) return(invisible(NULL))

  zip_dir <- path.expand(zip_dir)
  zip_files <- list.files(zip_dir, pattern = "\\.zip$", full.names = TRUE)

  if (length(zip_files) == 0) {
    message("No zip files found in ", zip_dir)
    return(invisible(NULL))
  }

  message(sprintf("\nUploading %d files to %s...", length(zip_files), bucket))

  cmd <- sprintf("gsutil -m cp %s/*.zip %s/", zip_dir, bucket)
  result <- system(cmd)

  if (result == 0) {
    message("Upload to GCS complete!")
  } else {
    warning("GCS upload had issues. Check authentication.")
  }

  invisible(result == 0)
}

#' Ingest shapefiles from GCS to GEE
ingest_to_gee <- function(zip_dir,
                          bucket = "gs://silica-synthesis-shapefiles",
                          asset_folder = "projects/silica-synthesis/assets/silica-watersheds") {
  if (!check_cli_tools()) return(invisible(NULL))

  zip_dir <- path.expand(zip_dir)
  zip_files <- list.files(zip_dir, pattern = "\\.zip$", full.names = FALSE)

  if (length(zip_files) == 0) {
    message("No zip files found in ", zip_dir)
    return(invisible(NULL))
  }

  message(sprintf("\nIngesting %d files to GEE...", length(zip_files)))

  success <- 0
  for (zf in zip_files) {
    asset_name <- tools::file_path_sans_ext(zf)
    gcs_path <- file.path(bucket, zf)
    asset_path <- file.path(asset_folder, asset_name)

    cmd <- sprintf("earthengine upload table --asset_id=%s %s", asset_path, gcs_path)
    result <- system(cmd, ignore.stdout = TRUE, ignore.stderr = TRUE)

    if (result == 0) success <- success + 1
  }

  message(sprintf("\nStarted %d/%d upload tasks", success, length(zip_files)))
  message("Check progress at: https://code.earthengine.google.com/ (Tasks tab)")

  invisible(success)
}

#' Complete workflow: process shapefiles and upload to GEE
#'
#' @param input_dir Folder containing raw shapefiles
#' @param output_dir Folder for processed/zipped files (default: tempdir)
#' @param upload Whether to upload to GEE after processing (default: TRUE)
#'
#' @examples
#' # Process and upload new shapefiles
#' upload_shapefiles_to_gee("~/Downloads/new-shapefiles")
#'
#' # Just process, don't upload yet
#' upload_shapefiles_to_gee("~/Downloads/new-shapefiles", upload = FALSE)
upload_shapefiles_to_gee <- function(input_dir,
                                      output_dir = file.path(tempdir(), "gee-upload"),
                                      upload = TRUE) {

  # Step 1: Process shapefiles (normalize names, reproject, zip)
  message("=== Step 1: Processing shapefiles ===\n")
  results <- process_all_shapefiles(input_dir, output_dir)

  if (!upload) {
    message("\nProcessing complete. Zips ready in: ", file.path(output_dir, "zipped"))
    message("To upload later, run:")
    message(sprintf('  upload_to_gcs("%s/zipped")', output_dir))
    message(sprintf('  ingest_to_gee("%s/zipped")', output_dir))
    return(invisible(results))
  }

  # Step 2: Upload to GCS
  message("\n=== Step 2: Uploading to Google Cloud Storage ===")
  zip_dir <- file.path(output_dir, "zipped")
  gcs_ok <- upload_to_gcs(zip_dir)

  if (!isTRUE(gcs_ok)) {
    message("\nGCS upload failed. Fix issues and run:")
    message(sprintf('  upload_to_gcs("%s")', zip_dir))
    return(invisible(results))
  }

  # Step 3: Ingest to GEE
  message("\n=== Step 3: Ingesting to Google Earth Engine ===")
  ingest_to_gee(zip_dir)

  message("\n=== All done! ===")
  invisible(results)
}

# ---- Execute ----
if (!interactive()) {
  results <- process_all_shapefiles(INPUT_DIR, OUTPUT_DIR)
}
