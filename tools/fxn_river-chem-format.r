#' @title Format Data in Standard 'River Chemistry' Structure
#' 
#' @description Accepts tabular data of river discharge/chemistry information and gets it into the preferred format for this synthesis effort. The primary facets of this standardization are (1) removal of unwanted columns and (2) standardization of column names.
#' 
#' @param river (data.frame) Tabular discharge/chemistry data to be standardized
#' @param date_col (character) Name of column containing date information. Must exactly match a column name in data supplied to `river`
#' @param var_col (character) Name of column containing variable information (e.g., discharge, DSi). If not found in `river`, is assumed to be the variable for all rows `river`
#' @param unit_col (character) Name of column containing units. If not found in `river`, is assumed to be the unit for all rows `river`
#' @param value_col (character) Name of column. Must exactly match a column name in data supplied to `river`
#' 
#' @return (data.frame) Standardized data frame with four columns and as many rows as there are unique combinations of those columns
#' 
river_chem_format <- function(river = NULL, date_col = "date", var_col = "variable", 
    unit_col = "units", value_col = "value"){

    # Error checks for 'river'
    if(is.null(river) || "data.frame" %in% class(river) != TRUE)
        stop("'river' must be supplied and data.frame-like")

    # Error checks for 'date_col'
    if(is.null(date_col) || length(date_col) != 1 || is.character(date_col) != TRUE || 
        date_col %in% names(river) != TRUE)
        stop("'date_col' must exactly match one column name in data passed to 'river' argument")
    
    # Error checks for 'var_col'
    if(is.null(var_col) || length(var_col) != 1 || is.character(var_col) != TRUE)
        stop("'var_col' must be a character vector containing only one element")

    # Warning checks for 'var_col'
    if(var_col %in% names(river) != TRUE){
        warning("'var_col' does not exactly match any column names in 'river'. It is now assumed to be the variable measured in all rows of 'river'") }
    
    # Error checks for 'unit_col'
    if(is.null(unit_col) || length(unit_col) != 1 || is.character(unit_col) != TRUE)
        stop("'unit_col' must be a character vector containing only one element")

    # Warning checks for 'unit_col'
    if(unit_col %in% names(river) != TRUE){
        warning("'unit_col' does not exactly match any column names in 'river'. It is now assumed to be the unit for the measurements in all rows of 'river'") }
    
    # Error checks for 'value_col'
    if(is.null(value_col) || length(value_col) != 1 || is.character(value_col) != TRUE || 
        value_col %in% names(river) != TRUE)
        stop("'value_col' must exactly match one column name in data passed to 'river' argument")
   
    # Grab each part of the data
    river_date <- dplyr::select(.data = river, dplyr::all_of(date_col))
    river_value <- dplyr::select(.data = river, dplyr::all_of(value_col))
    ## Conditionally grab variable/unit per warning text above
    if(var_col %in% names(river)){
        river_variable <- dplyr::select(.data = river, dplyr::all_of(var_col))
    } else { river_variable <- rep(x = var_col, times = nrow(river)) }
    if(unit_col %in% names(river)){
        river_unit <- dplyr::select(.data = river, dplyr::all_of(unit_col))
    } else { river_unit <- rep(x = unit_col, times = nrow(river)) }

    # Assemble into table of desired format
    river_std <- data.frame(
        "date" = river_date,
        "variable" = river_variable,
        "unit" = river_unit,
        "value" = river_value)

    # Return that
    return(river_std) }

# End ----
