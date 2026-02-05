#!/usr/bin/env python3
"""
Prepare shapefiles for GEE upload by zipping related files together.
Each shapefile consists of .shp, .shx, .dbf, .prj (and optionally .cpg, .sbn, .sbx)
"""

import os
import zipfile
from pathlib import Path
from collections import defaultdict

# Configuration
INPUT_DIR = Path.home() / "Downloads/silica-shapefiles/artisanal-shapefiles-2"
OUTPUT_DIR = Path.home() / "Downloads/silica-shapefiles/zipped-for-gee"

def main():
    # Create output directory
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Group files by base name
    files_by_basename = defaultdict(list)
    shapefile_extensions = {'.shp', '.shx', '.dbf', '.prj', '.cpg', '.sbn', '.sbx', '.xml'}

    for f in INPUT_DIR.iterdir():
        if f.is_file() and f.suffix.lower() in shapefile_extensions:
            basename = f.stem
            files_by_basename[basename].append(f)

    print(f"Found {len(files_by_basename)} shapefiles to zip")

    # Create zip for each shapefile
    success_count = 0
    for basename, files in sorted(files_by_basename.items()):
        # Check that we have the essential files
        extensions = {f.suffix.lower() for f in files}
        if '.shp' not in extensions:
            print(f"  Skipping {basename}: no .shp file")
            continue

        zip_path = OUTPUT_DIR / f"{basename}.zip"
        try:
            with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zf:
                for f in files:
                    zf.write(f, f.name)
            success_count += 1
        except Exception as e:
            print(f"  Error zipping {basename}: {e}")

    print(f"\nCreated {success_count} zip files in {OUTPUT_DIR}")
    print(f"\nNext step: Upload these to GEE using the Code Editor or earthengine CLI")

if __name__ == "__main__":
    main()
