# Spatial Workflow

**Modernization Author:** Sidney Bush

---

## Changelog

### 2026-02-04: Starting GEE migration

Moving away from AppEEARS workflow to Google Earth Engine. Copying shapefiles to GEE Assets and HydroShare for backup.

**GEE Upload Status:**
- 687 shapefiles prepared and zipped in `~/Downloads/silica-shapefiles/zipped-for-gee/`
- Upload scripts in `gee-upload/` folder
- Next: Configure GEE cloud project, then run batch upload

**Missing Shapefiles (need to create/find):**
- `lvws_basin` (ColoradoAlpine - Loch Vale)
- `V3015810`, `V301502401`, `V301502402` (Yzeron sites)

**Shapefiles to derive from HydroSHEDS:**
- WesternAustralia (13 sites) - large rivers, suitable for HydroSHEDS
- See `gee-upload/derive_western_australia.js`

**Shapefiles needing expert input (too small for HydroSHEDS):**
- ColoradoAlpine (11 sites, <10 km²)
- ARC Arctic (39 sites, <10 km²)

#### Current Data Storage: NCEAS Server

Path: `/home/shares/lter-si/si-watershed-extract/`

**Shapefiles in site-coordinates/ (explained):**

| File | Size | What it is | Status |
|------|------|------------|--------|
| `silica-watersheds.shp` | 120M | Combined file (artisanal + hydrosheds) | **Use this** - main file for extractions |
| `silica-watersheds_artisanal.shp` | 120M | Expert-provided watersheds combined | Input to combined file |
| `silica-watersheds_hydrosheds.shp` | 543K | HydroSHEDS-derived watersheds (original) | Input to combined file |
| `silica-watersheds_hydrosheds_DR_2.shp` | 121M | HydroSHEDS watersheds, Data Release 2 | Created by wrangle-hydrosheds.R |
| `CROPPED-silica-watersheds.shp` | 6M | Old cropped version | **Deprecated** - from old script |

**How combined file is built** (see `wrangle-watersheds.R`):
```
silica-watersheds_artisanal.shp + silica-watersheds_hydrosheds.shp → silica-watersheds.shp
```

**Individual shapefiles:**
- `artisanal-shapefiles-2/` — 687 individual expert-provided watershed files (upload these to GEE)

### New Sites Added (2026-02-04)

**ColoradoAlpine** (12 sites - need shapefiles derived from coordinates):
- sky, andrewstarn, andrewscreek, loch (has lvws_basin), haiyaha, emerald, louise, fern, glass, husted, littlelochcreek, odessa

**Yzeron** (3 sites):
- V3015810 (Mercier au pont D610)
- V301502401 (Ratier à Saint-Genis-les-Ollières)
- V301502402 (Ratier à Ponterle)

**Seine** (38 sites - cdstation_national_* shapefiles):
- 3080660 (IVRY_SUR_SEINE), 3081000 (ARRONDISSEMENT_12), 3081570, 3082000, 3082560, 3083000, 3083450, 3084470, 3085000
- 3125000 (CARRIERES_SOUS_POISSY), 3125500 (TRIEL_SUR_SEINE), 3126000, 3127370, 3128000 (BENNECOURT)
- 3172510, 3173250, 3174000 (AMFREVILLE_SOUS_LES_MONTS), 3174110 (POSES_3), 3174210, 3174211
- 3182630, 3183000, 3183460, 3183580, 3183730, 3183800, 3184000, 3184120, 3184370, 3184530, 3184760, 3184880, 3185000, 3185210, 3185610, 3186000, 3186234, 3186500

**Guadeloupe** (6 sites):
- GRCBDMDF (Maison de la Forêt), GRCBDPBD (Ravine Quiock), GRCBDQCK (Petit Bras-David)
- GRCCEDIG (Capesterre, La Digue), GRCVHBAR (Vieux-Habitants, Barthole), GRCVHSAV (Vieux-Habitants, Savanne-Beauséjour)

**ARC - Arctic** (39 sites - need shapefiles derived from coordinates):
- E 01 into Toolik, E 05 Inlet South/West/Outlet, I Swamp Outlet, I4-I9 sites
- Imnavait WT 08-01 through 08-15 (13 sites)
- LTER 345/346 sites, Milake, Milkyway Lower/Upper, NE 14, Toolik Outlet
- TW 01-14 and TW Lower

**WesternAustralia** (13 sites - need shapefiles):
- 604053 (Kent River), 605012 (Frankland River), 608151 (Donnelly River), 609025 (Blackwood River)
- 611026 (Ferguson River), 611111 (Thomson Brook), 612034/612035 (Collie River)
- 614006 (Murray River), 614044 (Yarragil Brook), 617058 (Gingin Brook)
- 704139 (Gascoyne River), 802055 (Fitzroy River)

**EastRiverSFA** (12 sites - shapefiles from StreamStats):
- Cement_Shapefile, CoalCreek, Bradley_Shapefile, Copper_Shapefile
- EAQ_Shapefile, EBC_Shapefile, Pumphouse_Shapefile, Rock_Shapefile
- Rustlers_Shapefile, Lottis_Shapefile, Snodgrass_Shapefile, Trail_Shapefile

#### Raster Data: AppEEARS vs GEE Equivalents

| Variable | AppEEARS Source | GEE Equivalent | Notes |
|----------|---------------|----------------|-------|
| Elevation | `raw-elevation/` (SRTM) | `USGS/SRTMGL1_003` | Same source, should match |
| Land Cover | `raw-glcc-landcover-data/` (GLCC) | `MODIS/061/MCD12Q1` | **DIFFERENT** - AppEEARS uses GLCC, GEE has MODIS. May need to verify classification scheme |
| NPP | `raw-npp-v061/` (MODIS MOD17A3) | `MODIS/061/MOD17A3HGF` | Same product, v061 |
| Evapotranspiration | `raw-evapo-modis16a2-v061/` | `MODIS/061/MOD16A2` | Same product, v061 |
| Air Temperature | `raw-airtemp-monthly/` | `ECMWF/ERA5_LAND/MONTHLY_AGGR` | Switching to ERA5-Land for monthly analysis capability |
| Precipitation | `raw-gpcp-precip/` (GPCP) | `ECMWF/ERA5_LAND/MONTHLY_AGGR` | Switching to ERA5-Land for consistency (monthly analysis) |
| Snow Fraction | `raw-snowfrac/` (MODIS MOD10A1) | `MODIS/061/MOD10A1` | Same product |
| Greenup | `raw-greenup-v061/` (MODIS MCD12Q2) | `MODIS/061/MCD12Q2` | Same product, v061 |
| Permafrost | `raw-permafrost/` | TBD | Need to identify GEE equivalent |
| Soil | `raw-soil/` | `OpenLandMap/SOL/SOL_*` | **VERIFY** - check if same source |
| Lithology | `raw-lithology-data/` (GLiM) | `projects/sat-io/open-datasets/GLiM` | Same source (community upload) |

**To do:**
- [ ] Verify air temperature source matches
- [ ] Document precipitation product difference (GPCP vs IMERG) - may affect comparability
- [ ] Verify soil data source
- [ ] Find/upload permafrost equivalent
- [ ] Test extraction results between old and new workflow for validation

---

## Original Documentation

# From poles to tropics: A multi-biome synthesis investigating the controls on river Si exports

- Primary Investigators: Joanna Carey & Kathi Jo Jankowski
- [Project Summary](https://lternet.edu/working-groups/river-si-exports/)
- [Participant Information](https://www.nceas.ucsb.edu/projects/12816)

## Script Explanations

Scripts in this repository are described below:

- **total-workflow.R** - Runs (1) `wrangle-watersheds.R` then (2) all `extract-[...].R` scripts plus a deletion of superseded "partial extract" CSVs and finished by running (3) `combine-drivers.R`. See below for descriptions of each of those scripts

- **wrangle-watersheds.R** - Processes watershed shapefiles into a single shapefile with all watersheds included. Starting shapefiles retrieved from site experts / various online sources. See the Reference Table for more information on these files (e.g., name, origin, CRS, etc.)

- **extract-[...].R** - These scripts are each responsible for extracting, summarizing, and exporting the spatial data type included in the script name. Each script uses the watersheds identified by "wrangle-watersheds.R" but is otherwise completely independent of other scripts in this repo

- **combine-drivers.R** - This script identifies all drivers that have been extracted and combines them into a single, analysis-ready file. This saves the analytical team(s) from needing to do this joining themselves.

#### Ancillary Scripts

- **appears-bbox-check.R** - Checks whether the site shapefiles fit inside of the manually-drawn [AppEEARS](https://appeears.earthdatacloud.nasa.gov/) bounding boxes. Used to be a sub-section of each `extract-...` script but it's easier to just centralize this check in a separate script.

- **crop-drivers.R** - For the drivers downloaded from [AppEEARS](https://appeears.earthdatacloud.nasa.gov/), data are retrieved from manually-drawn  bounding boxes. These bounding boxes intentionally overlap each other somewhat so that no gaps exist between downloads but this does necessitate cropping those boxes to avoid "double counting" the pixels contained in two separate bounding boxes. This script does all of that cropping.

    - AppEEARS data acquisition process is as follows:
    - 1) Sign into AppEEARS portal (create account if you don't already have one)
    - 2) Click "Extract" in top left of navbar at top of screen
    - 3) Select "Area" in the resulting dropdown menu
    - 4) Either start a new request of use an existing request if you want to use the bounding box drawn for a previous request
    - 5A) Name your request informatively
    - 5B) Draw bounding box / polygon for which you want data
    - 5C) Select range of dates for which you want data
    - 5D) Search for and add the data layers you want
    - 5E) Select the output format you desire
    - 5F) Select the coordinate reference system (CRS) for the output data
    - 5G) Click "Submit"
    - 6) Await email confirming 'download ready'
    - 7) Follow instructions to download the parts of the data / QA of your request that you want
    - NOTE: It is easy to exceed the data limitation of a single request either by (i) exceeding the spatial area allowed or (ii) including too many layers in the same request. It is better to make several smaller requests to avoid this issue.

## Related Repositories

This working group has several repositories. All are linked and described (briefly) below.

- [lter/**lterwg-silica-data**](https://github.com/lter/lterwg-silica-data) - Primary data wrangling / tidying repository for "master" data files
- [SwampThingPaul/**SiSyn**](https://github.com/SwampThingPaul/SiSyn) - Original repository for this working group. Performs many functions from data wrangling through analysis and figure creation
- [lsethna/**NCEAS_SiSyn_CQ**](https://github.com/lsethna/NCEAS_SiSyn_CQ) - Examples concentration (C) and discharge (Q) relationships for a wide range of solutes
- [lter/**lterwg-silica-spatial**](https://github.com/lter/lterwg-silica-spatial) - Extracts spatial and climatic information from within watershed shapefiles
- [njlyon0/**lter_silica-high-latitude**](https://github.com/njlyon0/lter_silica-high-latitude) - Performs analysis and visualization for the high latitude manuscript
