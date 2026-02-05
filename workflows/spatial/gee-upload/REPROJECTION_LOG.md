# Shapefile Reprojection Log

Documentation of CRS fixes applied during GEE upload (2026-02-05).

## Summary

- **650 shapefiles** uploaded without issues (already in WGS84)
- **37 shapefiles** required reprojection to WGS84 (EPSG:4326)

## Files Requiring Reprojection

### Eckert IV → WGS84 (20 files)

These files were stored in Eckert IV equal-area projection but the .prj files were missing or incorrect.

| Site | Original CRS | Region |
|------|--------------|--------|
| amazon_obidos | Eckert IV | Amazon/HYBAM |
| amazon_manacapuru | Eckert IV | Amazon/HYBAM |
| amazon_santoantonio | Eckert IV | Amazon/HYBAM |
| amazon_vergemgrande | Eckert IV | Amazon/HYBAM |
| atalaya_aval | Eckert IV | Amazon/HYBAM |
| borja | Eckert IV | Amazon/HYBAM |
| caracarai | Eckert IV | Amazon/HYBAM |
| cuidad_bolivar | Eckert IV | Amazon/HYBAM |
| franscisco | Eckert IV | Amazon/HYBAM |
| itaituba | Eckert IV | Amazon/HYBAM |
| itapeua | Eckert IV | Amazon/HYBAM |
| langa_tabiki | Eckert IV | Amazon/HYBAM |
| manacapuru | Eckert IV | Amazon/HYBAM |
| nazareth | Eckert IV | Amazon/HYBAM |
| porto_velho | Eckert IV | Amazon/HYBAM |
| rio_ica | Eckert IV | Amazon/HYBAM |
| rio_japura | Eckert IV | Amazon/HYBAM |
| rio_jurua | Eckert IV | Amazon/HYBAM |
| rio_jutai | Eckert IV | Amazon/HYBAM |
| rio_madeira | Eckert IV | Amazon/HYBAM |
| rio_negro | Eckert IV | Amazon/HYBAM |
| rio_purus | Eckert IV | Amazon/HYBAM |
| rurrenabaque | Eckert IV | Amazon/HYBAM |
| saut_maripa | Eckert IV | Amazon/HYBAM |
| congo_brazzaville | Eckert IV | Africa |
| niger_bamako | Eckert IV | Mali |
| elberiver | Eckert IV | Europe |

### UTM Zone 32N (EPSG:32632) → WGS84 (5 files)

These files had .prj files claiming WGS84 but coordinates were in meters (UTM).

| Site | Original CRS | Region |
|------|--------------|--------|
| awout_messam | UTM 32N | Cameroon |
| nyong_ayos | UTM 32N | Cameroon |
| nyong_mbalmayo | UTM 32N | Cameroon |
| nyong_olama | UTM 32N | Cameroon |
| soo_pontsoo | UTM 32N | Cameroon |

### Finnish TM35FIN (EPSG:3067) → WGS84 (1 file)

| Site | Original CRS | Region |
|------|--------------|--------|
| vilajoen_vesistoalue | EPSG:3067 | Finland |

### Already Correct (5 files)

These had valid WGS84 coordinates but GEE initially failed (geometry issues fixed):

| Site | Region |
|------|--------|
| grcbdpbd | Guadeloupe |
| grcbdqck | Guadeloupe |
| grcvhbar | Guadeloupe |
| grcvhsav | Guadeloupe |

## How CRS Was Determined

1. Checked reference table (`silica-coords_RAW.xlsx`) for documented CRS
2. Analyzed coordinate bounding boxes to identify projection type
3. Cross-referenced with known UTM zones for geographic regions

## Prevention for Future Uploads

All new shapefiles should be processed through:
```r
source("workflows/utils/prepare_shapefiles_for_gee.R")
```

This script:
1. Normalizes site names (lowercase, underscores)
2. Checks/assigns CRS from reference table
3. Reprojects to WGS84 (EPSG:4326)
4. Validates geometry
5. Zips for GEE upload
