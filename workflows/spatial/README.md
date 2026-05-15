# Spatial Workflow

This folder is the transition point for the active GEE-oriented upstream spatial workflow under the `global-river-chem` umbrella.

## Current Top-Level Scope

Keep at the top level only things that are part of the active GEE direction:
- GEE upload and setup material in `gee-upload/`
- workflow cleanup/planning notes
- top-level repo metadata

## Legacy Pre-GEE Workflow

The older extraction workflow has been moved to:
- `deprecated/legacy_pre_gee/`

That includes the older:
- `extract-*.R` scripts
- `wrangle-*.R` scripts
- `combine-drivers.R`
- `total-workflow.R`

## Relationship To Other Repos

- `lterwg-silica-spatial`
  Legacy pre-GEE extraction repo to finalize and archive

- `data-workflow/workflows/spatial`
  Active upstream GEE-oriented workflow location

- `spatial-qaqc`
  Downstream spatial QA/QC and harmonization repo

- `ESOM`
  Separate ESOM comparison repo

## Next Cleanup Steps

1. Rename this folder to `gee_spatial`.
2. Keep building the active GEE workflow at the top level.
3. Port over only the specific old-workflow fixes still needed from `lterwg-silica-spatial`.
4. Avoid restoring the full pre-GEE extraction workflow to the top level.
