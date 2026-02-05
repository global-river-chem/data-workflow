# Data Workflow

**Modernization Author:** Sidney Bush

---

## Changelog

### 2026-02-04: Started reviewing harmonization scripts

Looking at `00-harmonize_chemistry.R` and `00-harmonize_discharge.R` to figure out what can be streamlined.

#### Current State: `00-harmonize_chemistry.R` (1390 lines)

**What it does:**
1. Downloads data key + units key from Google Drive
2. Downloads raw chemistry files from Google Drive
3. For each file: renames columns via data key, handles long/wide formats
4. Big-picture checks (missing dataset info, stream names)
5. Numeric checks (malformed numbers, -9999 values)
6. Column name standardization (coalescing ~30 variants like pH, ph, pH_pH into single columns)
7. Unit conversions (mg/L → uM using molecular weights)
8. Outlier removal (>4 SD from mean)
9. Site-specific fixes (Finnish names, duplicate NO3/NOx removal)
10. Date parsing (manual format detection per filename)
11. Export to Google Drive

**Things to improve:**
- Hardcoded NCEAS server paths (`/home/shares/lter-si/WRTDS`)
- Heavy Google Drive dependency throughout
- ~200 lines of manual column coalescing (lines 430-600)
- Manual date format detection by filename (lines 1228-1275)
- 15+ intermediate objects (`tidy_v0` through `tidy_v8f`) - hard to track
- Hardcoded site-specific fixes scattered throughout
- No modular functions - single linear script
- No config file for column mappings or unit conversions

#### Current State: `00-harmonize_discharge.R` (360 lines)

**What it does:**
1. Downloads reference table from Google Drive
2. Downloads discharge files from Google Drive
3. Renames columns using hardcoded lists
4. Converts units to CMS (cubic meters/second)
5. Date conversion
6. QC checks (negative values, NA dates)
7. Join with reference table for stream names
8. Export to Google Drive

**Things to improve:**
- Uses `setwd()` multiple times - bad practice, breaks reproducibility
- Hardcoded paths to NCEAS server
- Manual column name lists (DischargeList, DateList)
- Dead code at bottom (~80 lines of commented/unused Australia processing)
- Loads `plyr` before `dplyr` - known conflict issue
- Inconsistent `require()` vs `library()` usage

---

### Planned Modernization (Phase 2)

**Priority changes:**
- [ ] Extract column mappings to config files (YAML/JSON)
- [ ] Extract unit conversion factors to config
- [ ] Replace hardcoded paths with environment variables or config
- [ ] Modularize into functions (read, clean, convert, export)
- [ ] Remove dead code from discharge script
- [ ] Standardize date parsing (use `lubridate::parse_date_time` with multiple formats)
- [ ] Add logging for QC steps
- [ ] Consider replacing Google Drive with local/cloud-agnostic storage option

---

## Original Documentation

# From poles to tropics: A multi-biome synthesis investigating the controls on river Si exports

- Primary Investigators: Joanna Carey & Kathi Jo Jankowski
- [Project Summary](https://lternet.edu/working-groups/river-si-exports/)
- [Participant Information](https://www.nceas.ucsb.edu/projects/12816)

## Script Explanations

### Data Harmonizing (`00`)

As with many synthesis projects, this work involves "harmonizing" many separate data files (i.e., rendering them comparable then combining them).

- `00-harmonize_chemistry.R`: **Combines individual _chemistry_ files (river / stream gage level) into a single file.** This is done with virtually no filtering to minimize data loss from this process
    - _When to Use:_ you want to integrate new _chemistry_ data into the 'master' file

- `00-harmonize_discharge.R`: **Combines individual _discharge_ files (river / stream gage level) into a single file.** This is done with virtually no filtering to minimize data loss from this process
    - _When to Use:_ you want to integrate new _discharge_ data into the 'master' file

### WRTDS (`01`)

WRTDS (Weighted Regressions on Time, Discharge, and Season) is a group of workflows necessary to process the harmonized discharge and chemistry data (see `00`) into data that are analysis-ready for a larger suite of further analyses. It does require several 'steps' be taken--in order--and these are preserved as separate scripts for ease of maintenance.

- `01-wrtds-step01_find-areas.R`: **Identifies the drainage basin area (in km^2) for all rivers.** Uses either the expert-provided area in the [reference table GoogleSheet](https://docs.google.com/spreadsheets/d/11t9YYTzN_T12VAQhHuY5TpVjGS50ymNmKznJK4rKTIU/edit#gid=357814834) or calculates it from DEM data.
    - _When to Use:_ you want to add new rivers to the WRTDS workflow

- `01-wrtds-step02_wrangling.R`: **Does all pre-WRTDS wrangling to (1) master chemistry, (2) master discharge, and (3) reference table files.** Includes a "sabotage check" looking for any sites dropped by that wrangling.
    - _When to Use:_ one of the three input files has been updated

- `01-wrtds-step03_analysis.R`: **Actually runs WRTDS.**
    - _When to Use:_ you've tweaked the WRTDS workflow and/or want to update results

- `01-wrtds-step03b_bootstrap.R`: **Runs the 'bootstrap' variant of WRTDS.** _This script is optional_ and is separate from `step03` because (A) it takes _much_ longer to run and (B) we don't run it as often as the 'main' WRTDS analysis script
    - _When to Use:_ you've tweaked the _bootstrap_ workflow and/or want to update its results

- `01-wrtds-step04_results-report.R`: **Creates single results output files for each type of WRTDS output.**
    - _When to Use:_ you want to generate new summary files

### Data Down/Upload (`99`) - _INTERNAL USE ONLY_

This group makes extensive use of Google Drive for convenient storing/sharing of the outputs of these scripts. However, such interactions do require access to the groups' Shared Google Drive and thus include these operations directly in the code functionally makes the code only run-able by members of the group. To solve this, **all Google Drive interactions are isolated into a standalone script**. Only a member of this working group can run the script so all others must run the 'actual' workflow scripts (in order) to ensure they have the relevant inputs for each.

- `99-gdrive_download-upload.R`: **Downloads inputs and uploads outputs from/to the Shared Google Drive.**
    - _When to Use:_ you want to skip 'early' steps in the workflow by downloading their most recent outputs from the Drive

## Related Repositories

This working group has several repositories. All are linked and described (briefly) below.

- [lter/**lterwg-silica-data**](https://github.com/lter/lterwg-silica-data) - Primary data wrangling / tidying repository for "master" data files
- [lsethna/**NCEAS_SiSyn_CQ**](https://github.com/lsethna/NCEAS_SiSyn_CQ) - Examples concentration (C) and discharge (Q) relationships for a wide range of solutes
- [lter/**lterwg-silica-spatial**](https://github.com/lter/lterwg-silica-spatial) - Extracts spatial and climatic information from within watershed shapefiles
- [njlyon0/**lter_silica-high-latitude**](https://github.com/njlyon0/lter_silica-high-latitude) - Performs analysis and visualization for the high latitude manuscript
- [SwampThingPaul/**SiSyn**](https://github.com/SwampThingPaul/SiSyn) - Original repository for this working group. Performs many functions from data wrangling through analysis and figure creation
