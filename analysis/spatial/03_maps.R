#!/usr/bin/env Rscript
# 03_maps.R — static maps (no tmap/leaflet required; uses ggplot2 + sf)
library(sf); library(ggplot2)

library(dplyr)
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

# LISA choropleth
lisa_path <- "results/lga_lisa.gpkg"
if (file.exists(lisa_path)) {
  lga <- st_read(lisa_path, quiet=TRUE)
  # significance filter
  lga_sig <- lga %>% filter(!is.na(lisa_quad))
  q <- ggplot(lga) + geom_sf(aes(fill=lisa_quad), color=NA) +
    scale_fill_manual(values=c(HH="#d73027", LL="#4575b4", HL="#fee090", LH="#91bfdb"), na.value="grey90", name="LISA (p<0.05)") +
    theme_minimal() + labs(title="LISA clusters: urban agriculture density per LGA",
                           subtitle="HH=high-high, LL=low-low, HL/LH outliers; grey = n.s.", caption="Data: OSM Overpass (484 pts) + GADM 4.1 NGA_2 (775 LGAs)")
  ggsave("results/figures/lisa_map.png", q, width=8, height=7, dpi=300)
  cat("Wrote results/figures/lisa_map.png\n")
  # density histogram
  library(dplyr)
  h <- ggplot(st_drop_geometry(lga), aes(x=density)) + geom_histogram(bins=30, fill="grey40") + theme_minimal() +
    labs(title="Distribution of urban agriculture density per LGA", x="Points per km2", y="LGAs")
  ggsave("results/figures/density_hist.png", h, width=7, height=4, dpi=300)
  cat("Wrote results/figures/density_hist.png\n")
}
