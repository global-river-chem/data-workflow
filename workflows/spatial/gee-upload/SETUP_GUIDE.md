# GEE & Cloud Storage Setup Guide

Step-by-step guide for uploading watershed shapefiles to Google Earth Engine.

**Current Account:** Personal (sidneyabush@gmail.com)
**Future:** Consider creating a shared project account for institutional use.

---

## One-Time Setup

### 1. Install Google Cloud SDK

**Terminal (Mac):**
```bash
curl -o ~/google-cloud-cli.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-darwin-arm.tar.gz
tar -xzf ~/google-cloud-cli.tar.gz -C ~
~/google-cloud-sdk/install.sh --quiet
source ~/.bash_profile
```

### 2. Install Earth Engine CLI

**Terminal:**
```bash
pip install earthengine-api
```

### 3. Authenticate

**Terminal:**
```bash
gcloud auth login
gcloud config set project silica-synthesis
earthengine authenticate
earthengine set_project silica-synthesis
```

### 4. Enable Billing (if not already done)

**Website:**
https://console.cloud.google.com/billing/linkedaccount?project=silica-synthesis

---

## Uploading New Shapefiles

### Quick Start (R)

```r
source("workflows/utils/prepare_shapefiles_for_gee.R")

# Process and upload new shapefiles in one step
upload_shapefiles_to_gee("~/path/to/new/shapefiles")

# Or just process without uploading
upload_shapefiles_to_gee("~/path/to/new/shapefiles", upload = FALSE)
```

This function:
1. Normalizes site names (lowercase, underscores, no special chars)
2. Reprojects to WGS84 (required for GEE)
3. Validates and fixes geometries
4. Zips for upload
5. Uploads to Google Cloud Storage
6. Ingests to GEE

### Manual Steps (if needed)

If you need to run steps separately:

```r
# Step 1: Process shapefiles
results <- process_all_shapefiles(
  input_dir = "~/path/to/shapefiles",
  output_dir = "~/path/to/output"
)

# Step 2: Upload to GCS
upload_to_gcs("~/path/to/output/zipped")

# Step 3: Ingest to GEE
ingest_to_gee("~/path/to/output/zipped")
```

---

## Monitoring Progress

**Website (GEE Code Editor):**
https://code.earthengine.google.com/ → Tasks tab

**Terminal:**
```bash
# List pending tasks
earthengine task list | head -20

# Count assets
earthengine ls projects/silica-synthesis/assets/silica-watersheds | wc -l
```

---

## Clean Up GCS (After Upload Complete)

Once GEE ingestion is done, you can delete the staging files:

**Terminal:**
```bash
gsutil rm gs://silica-synthesis-shapefiles/*.zip
```

---

## Troubleshooting

**"billing account disabled"**
→ Link billing at https://console.cloud.google.com/billing

**"project not found" in earthengine**
→ Run `earthengine set_project silica-synthesis`

**Projection errors during upload**
→ Shapefile has wrong/missing CRS. See REPROJECTION_LOG.md for examples.

**Auth expired**
→ Re-run `gcloud auth login` and `earthengine authenticate`

---

## Project Structure

```
GEE Assets (projects/silica-synthesis/assets/)
├── silica-watersheds/     # Individual watershed polygons (687 sites)
├── chemistry/             # (Future) Chemistry data tables
└── discharge/             # (Future) Discharge data tables

GCS Bucket (gs://silica-synthesis-shapefiles/)
└── (temporary staging for uploads)
```

---

## R Dependencies

```r
install.packages(c("sf", "stringi", "zip"))
```
