#' Normalize site names to standard format
#'
#' Converts site names to: lowercase, underscores, no special characters.
#' Use this when importing data to ensure consistent naming.
#'
#' @param name Character string or vector of site names
#' @return Normalized name(s)
#'
#' @examples
#' normalize_site_name("Ahtavanjoen vesistoalue")
#' # Returns: "ahtavanjoen_vesistoalue"
#'
#' normalize_site_name("Vilajoen vesistöalue")
#' # Returns: "vilajoen_vesistoalue"

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

# Vectorized version
normalize_site_names <- function(names) {
  sapply(names, normalize_site_name, USE.NAMES = FALSE)
}

# Test if run directly
if (sys.nframe() == 0) {
  test_names <- c(
    "Ahtavanjoen vesistoalue",
    "UK_27006",
    "Vilajoen vesistöalue",
    "IVRY_SUR_SEINE",
    "East Fork Jemez River"
  )

  cat("Name normalization examples:\n\n")
  for (name in test_names) {
    cat(sprintf("  %-40s → %s\n", name, normalize_site_name(name)))
  }
}
