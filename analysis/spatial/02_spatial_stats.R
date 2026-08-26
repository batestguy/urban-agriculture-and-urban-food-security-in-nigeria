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
  dens <- joined %>% st_drop_geometry() %>% filter(!is.na(city)) %>% count(GID_2) %>% rename(lga=GID_2, n=n)
  lga <- left_join(lga, dens, by=c("GID_2"="lga"))
  lga$n[is.na(lga$n)] <- 0
  # area km2 (EPSG:4326 → transform to 26392 or use s2 area)
  lga$area_km2 <- as.numeric(st_area(lga)) / 1e6
  lga$density <- lga$n / pmax(lga$area_km2, 1)  # per km2
  # Neighbours — queen contiguity
  nb <- poly2nb(lga, queen=TRUE)
  lw <- nb2listw(nb, style="W", zero.policy=TRUE)
  # Global Moran's I on counts and density
  mi_n <- moran.test(lga$n, lw, zero.policy=TRUE)
  cat("Global Moran's I (counts n):\n"); print(mi_n)
  mi_d <- moran.test(lga$density, lw, zero.policy=TRUE)
  cat("Global Moran's I (density per km2):\n"); print(mi_d)
  # LISA on density (primary) and counts
  lisa_n <- localmoran(lga$n, lw, zero.policy=TRUE)
  lisa_d <- localmoran(lga$density, lw, zero.policy=TRUE)
  lga$lisa_I <- lisa_d[,"Ii"]; lga$lisa_p <- lisa_d[,"Pr(z != E(Ii))"]
  lga$lisa_I_n <- lisa_n[,"Ii"]; lga$lisa_p_n <- lisa_n[,"Pr(z != E(Ii))"]
  # Classify LISA quadrants (density)
  lga$lag_density <- lag.listw(lw, lga$density, zero.policy=TRUE)
  lga$lisa_quad <- with(lga, ifelse(lisa_p < 0.05,
    ifelse(density > mean(density) & lag_density > mean(density), "HH",
    ifelse(density < mean(density) & lag_density < mean(density), "LL",
    ifelse(density > mean(density) & lag_density < mean(density), "HL", "LH"))), NA))
  dir.create("results", showWarnings=FALSE)
  st_write(lga, "results/lga_lisa.gpkg", delete_dsn=TRUE, quiet=TRUE)
  # Spatial lag model stub — replace n ~ covariates (area, climate)
  # library(spatialreg); mod <- lagsarlm(density ~ log(area_km2), data=lga, listw=lw, zero.policy=TRUE); summary(mod)
  cat("Wrote results/lga_lisa.gpkg\n")
  # summary for manuscript Table 1
  cat(sprintf("LGA summary: n LGA=%d, LGAs with >0 UA points=%d (%.1f%%), max n=%d, max density=%.4f/km2\n",
    nrow(lga), sum(lga$n>0), 100*mean(lga$n>0), max(lga$n), max(lga$density)))
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
