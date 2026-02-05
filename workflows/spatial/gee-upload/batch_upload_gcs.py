#!/usr/bin/env python3
"""
Batch upload shapefiles from GCS to GEE.
Run after uploading zips to gs://silica-synthesis-shapefiles/
"""

import subprocess
import time
import sys

# Configuration
GCS_BUCKET = "gs://silica-synthesis-shapefiles"
GEE_ASSET_PATH = "projects/silica-synthesis/assets/silica-watersheds"

def run_command(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode == 0, result.stdout, result.stderr

def main():
    # List all zip files in GCS
    print("Listing files in GCS...")
    import os
    gsutil_path = os.path.expanduser("~/google-cloud-sdk/bin/gsutil")
    success, stdout, stderr = run_command(f"{gsutil_path} ls {GCS_BUCKET}/*.zip")

    if not success:
        print(f"Error listing GCS: {stderr}")
        sys.exit(1)

    gcs_files = [line.strip() for line in stdout.strip().split('\n') if line.strip()]
    print(f"Found {len(gcs_files)} files to ingest\n")

    # Track progress
    uploaded = 0
    failed = []
    skipped = []

    for i, gcs_path in enumerate(gcs_files, 1):
        # Extract asset name from path (e.g., gs://bucket/name.zip -> name)
        asset_name = gcs_path.split('/')[-1].replace('.zip', '')
        full_asset_path = f"{GEE_ASSET_PATH}/{asset_name}"

        # Check if already exists
        check_cmd = f'earthengine asset info {full_asset_path} 2>&1'
        success, stdout, _ = run_command(check_cmd)
        if success and "not found" not in stdout.lower() and "does not exist" not in stdout.lower():
            skipped.append(asset_name)
            print(f"[{i}/{len(gcs_files)}] Skipped (exists): {asset_name}")
            continue

        # Upload
        upload_cmd = f'earthengine upload table --asset_id={full_asset_path} {gcs_path}'
        success, stdout, stderr = run_command(upload_cmd)

        if success:
            uploaded += 1
            print(f"[{i}/{len(gcs_files)}] Started: {asset_name}")
        else:
            failed.append((asset_name, stderr))
            print(f"[{i}/{len(gcs_files)}] FAILED: {asset_name} - {stderr[:80]}")

        # Small delay to avoid rate limiting
        if i % 20 == 0:
            time.sleep(1)

    # Summary
    print(f"\n{'='*50}")
    print(f"Upload Summary:")
    print(f"  Started: {uploaded}")
    print(f"  Skipped (already exist): {len(skipped)}")
    print(f"  Failed: {len(failed)}")
    print(f"\nNote: Uploads run as background tasks in GEE.")
    print(f"Check progress at: https://code.earthengine.google.com/ (Tasks tab)")

    if failed:
        print(f"\nFailed uploads:")
        for name, err in failed[:10]:
            print(f"  - {name}: {err[:60]}")

if __name__ == "__main__":
    main()
