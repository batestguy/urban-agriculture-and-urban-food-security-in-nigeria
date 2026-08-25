#!/usr/bin/env Rscript
# 03_maps.R — static maps (no tmap/leaflet required; uses ggplot2 + sf)
library(sf); library(ggplot2)

osm_path <- "data/processed/osm_urban_ag.gpkg"
if (file.exists(osm_path)) {
  osm <- st_read(osm_path, quiet=TRUE)
  p <- ggplot() + geom_sf(data=osm, aes(color=city), size=1, alpha=0.7) +
    theme_minimal() + labs(title="Urban agriculture footprints (OSM Overpass — frozen)",
                           subtitle="Allotments/farmland/garden nodes per city", color="City")
  dir.create("results/figures", recursive=TRUE, showWarnings=FALSE)
  ggsave("results/figures/osm_points.png", p, width=8, height=6, dpi=300)
  cat("Wrote results/figures/osm_points.png\n")
} else cat("No", osm_path, "— run 01_clean.R after fetching OSM\n")
