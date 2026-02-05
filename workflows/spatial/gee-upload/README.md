# GEE Upload Instructions

## Setup Steps

1. **Go to GEE Code Editor**: https://code.earthengine.google.com/

2. **Create or note your Cloud Project**:
   - In the Code Editor, look at the Assets panel (left side)
   - Your asset path shows your project: `projects/ee-yourname/assets/`
   - If you don't have one, click the Cloud Project dropdown at top and create one

3. **Create the asset folder**:
   - In Assets panel, click "NEW" → "Folder"
   - Name it: `silica-watersheds`

4. **Configure CLI** (from terminal):
   ```bash
   earthengine set_project ee-yourname
   ```
   Replace `ee-yourname` with your actual project ID.

## Upload Options

### Option A: Batch Upload via CLI (687 files)

After setup, run:
```bash
cd /Users/sidneybush/Documents/GitHub/data-workflow/workflows/spatial/gee-upload
python3 batch_upload.py
```

This will upload all 687 zipped shapefiles to your `silica-watersheds` folder.

### Option B: Manual Upload via Code Editor

1. In Assets panel, navigate to your `silica-watersheds` folder
2. Click "NEW" → "Shape files"
3. Select all component files for one shapefile (.shp, .shx, .dbf, .prj)
4. Or upload a single .zip file containing all components
5. Repeat for each shapefile

Zip files are in: `~/Downloads/silica-shapefiles/zipped-for-gee/`

## Files in this folder

- `prepare_shapefiles.py` - Zips shapefile components for upload
- `batch_upload.py` - Batch uploads all zipped files to GEE
- `derive_western_australia.js` - GEE script to derive WA watersheds from HydroSHEDS

## Western Australia Watersheds

The 13 Western Australia sites need watersheds derived from HydroSHEDS (sites are large rivers, suitable for HydroSHEDS). See `derive_western_australia.js` for the GEE script.
