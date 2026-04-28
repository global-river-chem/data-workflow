# Spatial Workflow Cleanup Plan

## Current Situation

This folder is not a clean replacement for `lterwg-silica-spatial`.
It is a mixed state containing:
- copied old extraction workflow files
- local changes made after the copy
- new GEE migration/upload work

## Recommended Role

This folder should become the active upstream GEE-oriented spatial extraction workflow under the `global-river-chem` umbrella.

Related repos should be treated as:
- `lterwg-silica-spatial`: legacy pre-GEE extraction workflow, finalize and archive
- `spatial-qaqc`: downstream harmonization, finalized spatial, QA/QC, coast-distance merge
- `ESOM`: ESOM-specific site-list comparisons

## Recommended Rename

Rename:
- `workflows/spatial`

to:
- `workflows/gee_spatial`

Use `gee_spatial`, not `GEE_spatial`, to keep paths/script names consistent.

## Keep Active

These belong in the active upstream workflow because they are part of the GEE transition/current direction.

Keep at top level:
- `README.md`
- `gee-upload/README.md`
- `gee-upload/SETUP_GUIDE.md`
- `gee-upload/REPROJECTION_LOG.md`
- `gee-upload/derive_western_australia.js`
- workflow cleanup/planning notes

## Move To Deprecated Or Archive

Legacy/deprecated:
- older extraction and wrangling scripts now live under `deprecated/legacy_pre_gee/`

## Port From `lterwg-silica-spatial`

Do this selectively, not as a wholesale sync.

Likely ports to review carefully:
- updated extraction script logic in the shared driver scripts
- `combine-drivers.R` differences
- `wrangle-*` differences
- standardization fixes such as the Finnish stream-name update

## What Not To Do

Do not keep both `lterwg-silica-spatial` and this folder as active extraction workflows.

Do not try to make this folder a full mirror of `lterwg-silica-spatial`.
That would reintroduce old clutter and blur the new GEE-oriented boundary.

## Recommended Next Steps

1. Keep `deprecated/legacy_pre_gee/` for now while Aurora and the old repo are still operational references.
2. Rename this folder to `gee_spatial`.
3. Keep building the active GEE workflow at the top level.
4. Port only the specific old-workflow fixes still needed from `lterwg-silica-spatial`.
5. Delete `deprecated/legacy_pre_gee/` only after Aurora is stable and the legacy repo is archived.
