# GEE & Cloud Storage Setup Guide

Step-by-step guide for setting up Google Earth Engine and Cloud Storage for the silica synthesis project.

**Current Account:** Personal (sidneyabush@gmail.com)
**Future:** Maybe we can create a shared project account (e.g., silica-synthesis@gmail.com) for institutional use.

---

## 1. Google Earth Engine Setup

### Create/Register a GEE Project

**Website:**
1. Go to https://code.earthengine.google.com/
2. If prompted, sign in with your Google account
3. Click the project dropdown at top → "Register a new project"
4. Name it (e.g., `silica-synthesis`)
5. Complete the registration

### Install Earth Engine CLI

**Terminal:**
```bash
pip install earthengine-api
earthengine authenticate
earthengine set_project YOUR_PROJECT_NAME
```

### Create Asset Folder

**Website (GEE Code Editor):**
1. Click "Assets" panel (left side)
2. Click "NEW" → "Folder"
3. Name it `silica-watersheds`

---

## 2. Google Cloud Storage Setup

### Install Google Cloud SDK

**Terminal (Mac):**
```bash
curl -o ~/google-cloud-cli.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz
tar -xzf ~/google-cloud-cli.tar.gz -C ~
~/google-cloud-sdk/install.sh --quiet

# Then restart terminal or run:
source ~/.bash_profile
```

### Authenticate

**Terminal:**
```bash
gcloud auth login
gcloud config set project silica-synthesis
```

### Enable Billing

**Website:**
1. Go to: https://console.cloud.google.com/billing/linkedaccount?project=silica-synthesis
2. Link a billing account (free tier covers small uploads)

### Create Storage Bucket

**Terminal:**
```bash
gsutil mb -l us-central1 gs://silica-synthesis-shapefiles
```

---

## 3. Uploading New Shapefiles

### Prepare Files

1. Place new shapefiles in a folder (each shapefile = .shp, .shx, .dbf, .prj files)

2. **Terminal** - Normalize the names:
```bash
cd /path/to/new/shapefiles
python3 ~/Documents/GitHub/data-workflow/workflows/utils/normalize_site_names.py
```

3. **Terminal** - Zip each shapefile (key for storage limits - free tier is 5GB):
```bash
python3 ~/Documents/GitHub/data-workflow/workflows/spatial/gee-upload/prepare_shapefiles.py
```

### Upload to GCS

**Terminal:**
```bash
# Upload all zips to Cloud Storage
gsutil -m cp /path/to/zipped/*.zip gs://silica-synthesis-shapefiles/

# Verify upload
gsutil ls gs://silica-synthesis-shapefiles/
```

### Ingest to GEE

**Terminal:**
```bash
# Single file
earthengine upload table \
  --asset_id=projects/silica-synthesis/assets/silica-watersheds/SITE_NAME \
  gs://silica-synthesis-shapefiles/site_name.zip

# Batch upload (use the batch script)
python3 ~/Documents/GitHub/data-workflow/workflows/spatial/gee-upload/batch_upload_gcs.py
```

### Monitor Upload Progress

**Website (GEE Code Editor):**
- Click "Tasks" tab (right side panel)
- Shows all running/completed ingestion tasks

### Clean Up GCS (Optional)

**Terminal** - After GEE ingestion completes:
```bash
gsutil rm gs://silica-synthesis-shapefiles/*.zip
```

---

## 4. Verifying Assets in GEE

**Terminal:**
```bash
# List all assets
earthengine ls projects/silica-synthesis/assets/silica-watersheds

# Check specific asset
earthengine asset info projects/silica-synthesis/assets/silica-watersheds/site_name
```

**Website:**
- GEE Code Editor → Assets panel → silica-watersheds folder

---

## 5. Future: Chemistry & Discharge Data

The same GCS bucket and GEE project can store:
- Chemistry data (as tables/CSVs → GEE FeatureCollections)
- Discharge data (as tables/CSVs → GEE FeatureCollections)

**Terminal** - Upload process is similar:
```bash
# Upload CSV to GCS
gsutil cp chemistry_data.csv gs://silica-synthesis-shapefiles/data/

# Ingest to GEE as table
earthengine upload table \
  --asset_id=projects/silica-synthesis/assets/chemistry/master_chemistry \
  gs://silica-synthesis-shapefiles/data/chemistry_data.csv
```

---

## Troubleshooting

**"billing account disabled"**
→ Website: Link billing at https://console.cloud.google.com/billing

**"project not found" in earthengine**
→ Terminal: Run `earthengine set_project silica-synthesis`

**Spaces in filenames**
→ Terminal: Run the normalize script before uploading

**Auth expired**
→ Terminal: Re-run `gcloud auth login` and `earthengine authenticate`

---

## Project Structure

```
GEE Assets (projects/silica-synthesis/assets/)
├── silica-watersheds/     # Individual watershed polygons
│   ├── ahtavanjoen_vesistoalue
│   ├── uk_27006
│   └── ...
├── chemistry/             # (Future) Chemistry data tables
└── discharge/             # (Future) Discharge data tables

GCS Bucket (gs://silica-synthesis-shapefiles/)
└── (temporary staging for uploads)
```
