#!/usr/bin/env python3
"""
Batch upload zipped shapefiles to Google Earth Engine.

Before running:
1. Go to https://code.earthengine.google.com/
2. In the Code Editor, click on "Assets" tab (left panel)
3. Click "NEW" > "Folder" and create: silica-watersheds
4. Note your project ID (visible in the asset path, e.g., projects/ee-yourname/assets/)
5. Run: earthengine set_project <your-project-id>
6. Then run this script
"""

import subprocess
import os
from pathlib import Path
import time
import sys

# Configuration - UPDATE THESE
GEE_PROJECT = os.environ.get('GEE_PROJECT', 'silica-synthesis')  # Your GEE project
ASSET_FOLDER = 'silica-watersheds'  # Folder name in GEE assets
ZIP_DIR = Path.home() / "Downloads/silica-shapefiles/zipped-for-gee"

def run_command(cmd):
    """Run a shell command and return success status."""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode == 0, result.stdout, result.stderr

def main():
    # Check earthengine is configured
    success, _, stderr = run_command("earthengine ls 2>&1")
    if "not found" in str(stderr) or "no project" in str(stderr).lower():
        print("ERROR: GEE project not configured properly.")
        print("Please run: earthengine set_project <your-project-id>")
        print("Find your project ID in the GEE Code Editor Assets panel")
        sys.exit(1)

    # Get list of zip files
    zip_files = sorted(ZIP_DIR.glob("*.zip"))
    print(f"Found {len(zip_files)} shapefiles to upload")

    if not zip_files:
        print(f"No zip files found in {ZIP_DIR}")
        sys.exit(1)

    # Create asset folder if needed
    asset_path = f"projects/{GEE_PROJECT}/assets/{ASSET_FOLDER}"
    print(f"\nUploading to: {asset_path}")

    # Track progress
    uploaded = 0
    failed = []
    skipped = []

    for i, zip_file in enumerate(zip_files, 1):
        asset_name = zip_file.stem.replace(' ', '_').replace('.', '_')
        full_asset_path = f"{asset_path}/{asset_name}"

        # Check if already exists
        check_cmd = f'earthengine asset info {full_asset_path} 2>&1'
        success, stdout, _ = run_command(check_cmd)
        if success and "not found" not in stdout.lower():
            skipped.append(asset_name)
            print(f"[{i}/{len(zip_files)}] Skipped (exists): {asset_name}")
            continue

        # Upload
        upload_cmd = f'earthengine upload table --asset_id={full_asset_path} "{zip_file}"'
        success, stdout, stderr = run_command(upload_cmd)

        if success:
            uploaded += 1
            print(f"[{i}/{len(zip_files)}] Uploaded: {asset_name}")
        else:
            failed.append((asset_name, stderr))
            print(f"[{i}/{len(zip_files)}] FAILED: {asset_name} - {stderr[:100]}")

        # Small delay to avoid rate limiting
        if i % 10 == 0:
            time.sleep(1)

    # Summary
    print(f"\n{'='*50}")
    print(f"Upload Summary:")
    print(f"  Uploaded: {uploaded}")
    print(f"  Skipped (already exist): {len(skipped)}")
    print(f"  Failed: {len(failed)}")

    if failed:
        print(f"\nFailed uploads:")
        for name, err in failed[:10]:
            print(f"  - {name}: {err[:80]}")
        if len(failed) > 10:
            print(f"  ... and {len(failed)-10} more")

if __name__ == "__main__":
    main()
