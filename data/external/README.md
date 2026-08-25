# data/external — shapefiles & external dumps (not always committed)

- **GADM LGA boundaries:** Download `gadm41_NGA_2.shp` (LGA level 2) from https://gadm.org/download_country.html or HDX `NGA administrative boundaries`. Place unzipped shapefile trio (`.shp`, `.shx`, `.dbf`) here. Used by `analysis/spatial/02_spatial_stats.R` for Moran's I / LISA / spatial regression. Large — if >50 MB, keep locally on Drive D and omit from git (use `.gitignore` + Git LFS if needed).
- **FAOSTAT dump fallback:** If `scripts/fetch_fao.py` gets 403, manually download FAOSTAT Food Security CSV and save as `data/external/faostat_food_security.csv`; pipeline reads raw stub otherwise.
- **Attribution:** GADM CC BY; HDX OCHA; OSM ODbL.
