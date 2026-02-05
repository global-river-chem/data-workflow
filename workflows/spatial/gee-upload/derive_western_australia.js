/*
 * Western Australia Watershed Derivation using HydroBASINS
 *
 * Uses WWF HydroBASINS Level 12 (smallest sub-basins) to find
 * upstream contributing areas for each gauging station.
 *
 * Copy this script to the GEE Code Editor: https://code.earthengine.google.com/
 */

// HydroBASINS Level 12 for Australia (Oceania region)
// Note: If this asset isn't available, you may need to upload HydroBASINS
var hydrobasins = ee.FeatureCollection('WWF/HydroATLAS/v1/Basins/level12');

// Alternative: Use HydroSHEDS basins if HydroBASINS not available
// var hydrosheds = ee.Image('WWF/HydroSHEDS/15ACC');

// Western Australia gauging station coordinates
// TODO: Fill in actual coordinates from your reference table
var sites = ee.FeatureCollection([
  ee.Feature(ee.Geometry.Point([117.9, -34.9]), {site_id: '604053', name: 'Kent River'}),
  ee.Feature(ee.Geometry.Point([117.0, -34.5]), {site_id: '605012', name: 'Frankland River'}),
  ee.Feature(ee.Geometry.Point([115.8, -34.3]), {site_id: '608151', name: 'Donnelly River'}),
  ee.Feature(ee.Geometry.Point([115.7, -34.0]), {site_id: '609025', name: 'Blackwood River'}),
  ee.Feature(ee.Geometry.Point([115.9, -33.4]), {site_id: '611026', name: 'Ferguson River'}),
  ee.Feature(ee.Geometry.Point([115.9, -33.5]), {site_id: '611111', name: 'Thomson Brook'}),
  ee.Feature(ee.Geometry.Point([116.0, -33.3]), {site_id: '612034', name: 'Collie River'}),
  ee.Feature(ee.Geometry.Point([116.1, -33.3]), {site_id: '612035', name: 'Collie River 2'}),
  ee.Feature(ee.Geometry.Point([116.0, -32.8]), {site_id: '614006', name: 'Murray River'}),
  ee.Feature(ee.Geometry.Point([116.2, -32.8]), {site_id: '614044', name: 'Yarragil Brook'}),
  ee.Feature(ee.Geometry.Point([115.9, -31.5]), {site_id: '617058', name: 'Gingin Brook'}),
  ee.Feature(ee.Geometry.Point([115.0, -25.0]), {site_id: '704139', name: 'Gascoyne River'}),
  ee.Feature(ee.Geometry.Point([125.6, -18.2]), {site_id: '802055', name: 'Fitzroy River'})
]);

// Filter HydroBASINS to Australia region
var ausBasins = hydrobasins.filterBounds(
  ee.Geometry.Rectangle([112, -45, 154, -10])
);

// Function to find the basin containing a point and get upstream basins
function getUpstreamBasins(feature) {
  var point = feature.geometry();
  var siteId = feature.get('site_id');
  var siteName = feature.get('name');

  // Find the basin containing this point
  var containingBasin = ausBasins.filterBounds(point).first();

  // Get the HYBAS_ID to trace upstream
  var hybasId = containingBasin.get('HYBAS_ID');

  // For a complete watershed, you need to find all upstream basins
  // This requires tracing the NEXT_DOWN field recursively
  // Simplified: just return the containing basin for now
  // For full upstream, use a more complex algorithm or pre-processed data

  return ee.Feature(containingBasin.geometry(), {
    'site_id': siteId,
    'name': siteName,
    'hybas_id': hybasId,
    'area_km2': containingBasin.get('SUB_AREA')
  });
}

// Map over all sites
var watersheds = sites.map(getUpstreamBasins);

// Visualization
Map.centerObject(sites, 5);
Map.addLayer(ausBasins, {color: 'lightblue'}, 'HydroBASINS L12', false);
Map.addLayer(watersheds, {color: 'blue'}, 'Site Watersheds');
Map.addLayer(sites, {color: 'red'}, 'Gauge Locations');

// Print info
print('Sites to process:', sites.size());
print('Sample watershed:', watersheds.first());

// Export to asset
Export.table.toAsset({
  collection: watersheds,
  description: 'WA_watersheds_from_hydrobasins',
  assetId: 'silica-watersheds/WesternAustralia_HydroBASINS'
});

// Export as shapefile to Drive (backup)
Export.table.toDrive({
  collection: watersheds,
  description: 'WA_watersheds_shapefile',
  folder: 'GEE_exports',
  fileFormat: 'SHP'
});

/*
 * IMPORTANT NOTES:
 *
 * 1. Update the coordinates above with actual gauge locations from your reference table
 *
 * 2. This script finds the HydroBASINS level 12 basin containing each point.
 *    For the FULL upstream watershed, you need to trace upstream using the
 *    NEXT_DOWN field. This requires more complex processing.
 *
 * 3. Alternative: Use the HydroSHEDS 15-arc-second data with a watershed
 *    delineation algorithm (more complex but gives exact drainage area)
 *
 * 4. For large rivers like Fitzroy and Gascoyne, HydroBASINS level 06-08
 *    may be more appropriate than level 12
 */
