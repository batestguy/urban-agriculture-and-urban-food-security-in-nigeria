#!/usr/bin/env Rscript
# 01_clean.R — clean & join OSM + World Bank + NASA POWER layers
# Env: R 4.5.2 (sf 1.1.2, terra 1.9.46); no API calls here — reads frozen data/raw
library(sf); library(dplyr); library(readr)

raw_osm <- "data/raw/osm_urban_ag.csv"
raw_wb  <- "data/raw/worldbank_ng.csv"

if (file.exists(raw_osm)) {
  osm <- read_csv(raw_osm, show_col_types=FALSE)
  cat(sprintf("OSM rows: %d cities: %s\n", nrow(osm), paste(unique(osm$city), collapse=", ")))
  # to sf points
  osm_sf <- st_as_sf(osm %>% filter(!is.na(lat), !is.na(lon)), coords=c("lon","lat"), crs=4326)
  dir.create("data/processed", showWarnings=FALSE, recursive=TRUE)
  st_write(osm_sf, "data/processed/osm_urban_ag.gpkg", delete_dsn=TRUE, quiet=TRUE)
  cat("Wrote data/processed/osm_urban_ag.gpkg\n")
} else cat("No", raw_osm, "— run scripts/fetch_osm_urban_ag.py first\n")

if (file.exists(raw_wb)) {
  wb <- read_csv(raw_wb, show_col_types=FALSE)
  wb_wide <- wb %>% filter(!is.na(value)) %>% select(indicator, date, value) %>%
    tidyr::pivot_wider(names_from=indicator, values_from=value)
  dir.create("data/processed", showWarnings=FALSE, recursive=TRUE)
  write_csv(wb_wide, "data/processed/worldbank_ng_wide.csv")
  cat("Wrote data/processed/worldbank_ng_wide.csv\n")
}
cat("01_clean.R done\n")
