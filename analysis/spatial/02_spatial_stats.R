#!/usr/bin/env Rscript
# 02_spatial_stats.R — Moran's I, LISA, spatial lag/error
# Requires: OSM gpkg + LGA polygons (data/external/gadm41_NGA_2.shp or similar)
# If LGA shapefile absent, runs demo on synthetic grid
library(sf); library(spdep); library(dplyr)

# Try LGA polygons
lga_path <- "data/external/gadm41_NGA_2.shp"
if (file.exists(lga_path)) {
  lga <- st_read(lga_path, quiet=TRUE)
  # join urban ag density: counts per LGA
  osm <- st_read("data/processed/osm_urban_ag.gpkg", quiet=TRUE)
  joined <- st_join(lga, osm)
  dens <- joined %>% st_drop_geometry() %>% count(NAME_2) %>% rename(lga=NAME_2, n=n)
  lga <- left_join(lga, dens, by=c("NAME_2"="lga"))
  lga$n[is.na(lga$n)] <- 0
  # Neighbours — queen contiguity
  nb <- poly2nb(lga, queen=TRUE)
  lw <- nb2listw(nb, style="W", zero.policy=TRUE)
  # Global Moran's I on counts (placeholder for food-security indicator)
  mi <- moran.test(lga$n, lw, zero.policy=TRUE)
  cat("Global Moran's I:\n"); print(mi)
  # LISA
  lisa <- localmoran(lga$n, lw, zero.policy=TRUE)
  lga$lisa_I <- lisa[,"Ii"]; lga$lisa_p <- lisa[,"Pr(z != E(Ii))"]
  dir.create("results", showWarnings=FALSE)
  st_write(lga, "results/lga_lisa.gpkg", delete_dsn=TRUE, quiet=TRUE)
  # Spatial lag model stub — replace n ~ covariates
  # library(spatialreg); lagsarlm(n ~ 1, data=lga, listw=lw)
  cat("Wrote results/lga_lisa.gpkg\n")
} else {
  cat("No", lga_path, "\n")
  cat("Place GADM LGA shapefile at data/external/gadm41_NGA_2.shp (download from https://gadm.org or HDX).\n")
  cat("Running synthetic demo...\n")
  set.seed(1)
  grid <- st_make_grid(st_as_sfc(st_bbox(c(xmin=2.5, ymin=4.5, xmax=9, ymax=13), crs=4326)), n=c(10,10))
  grid <- st_as_sf(data.frame(id=1:length(grid), val=rnorm(length(grid))), geometry=grid)
  nb <- poly2nb(grid); lw <- nb2listw(nb, style="W")
  print(moran.test(grid$val, lw))
}
cat("02_spatial_stats.R done\n")
