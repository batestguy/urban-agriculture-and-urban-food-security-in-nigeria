#!/usr/bin/env Rscript
# 04_extra_figs.R — extra figures for richer manuscript (Phase 5+)
# Generates: density vs rainfall scatter, correlation heatmap, density by city boxplot
library(sf); library(dplyr); library(readr); library(ggplot2)

lga <- st_read("results/lga_lisa.gpkg", quiet=TRUE)
nasa <- read_csv("data/processed/nasa_annual.csv", show_col_types=FALSE)
# standardise city names
nasa$city <- tolower(nasa$city)
# Map NAME_1 (State) -> city for rainfall assignment
# GADM NAME_1: Federal Capital Territory, Lagos, Kano, Rivers, Gombe
state_to_city <- c(
  "Federal Capital Territory" = "abuja",
  "Lagos" = "lagos",
  "Kano" = "kano",
  "Rivers" = "port_harcourt",
  "Gombe" = "gombe"
)
lga$city_key <- state_to_city[lga$NAME_1]
# Only LGAs with points have city_key; keep all for density zero case
lga_df <- lga %>% st_drop_geometry() %>% as.data.frame()
# Join rainfall etc. where city_key matches
lga_df <- left_join(lga_df, nasa, by=c("city_key"="city"))
# Keep only LGAs with >0 points for scatter (39), otherwise rainfall NA for non-mapped states stays NA
scatter_df <- lga_df %>% filter(n > 0, !is.na(prectot_sum))
cat(sprintf("Scatter: %d LGAs with points and rainfall\n", nrow(scatter_df)))
print(scatter_df %>% select(NAME_2, NAME_1, n, density, prectot_sum, t2m_mean, rh2m_mean) %>% head(10))

# Correlation (Spearman) density vs climate
if (nrow(scatter_df) >= 5) {
  cor_res <- cor.test(scatter_df$density, scatter_df$prectot_sum, method="spearman")
  cat(sprintf("Spearman density vs rainfall: rho=%.3f p=%.4f\n", cor_res$estimate, cor_res$p.value))
  cor_res2 <- cor.test(scatter_df$density, scatter_df$t2m_mean, method="spearman")
  cat(sprintf("Spearman density vs T2M: rho=%.3f p=%.4f\n", cor_res2$estimate, cor_res2$p.value))
}

dir.create("results/figures", recursive=TRUE, showWarnings=FALSE)

# Fig 4: Density vs rainfall scatter (log scale not needed)
p1 <- ggplot(scatter_df, aes(x=prectot_sum, y=density, color=NAME_1)) +
  geom_point(size=3, alpha=0.85) +
  geom_smooth(method="lm", se=FALSE, color="grey30", linetype="dashed") +
  scale_color_brewer(palette="Set1", name="State") +
  theme_minimal(base_size=11) +
  labs(title="Urban agriculture density vs annual rainfall (2023)",
       subtitle="39 LGAs with ≥1 OSM point; Spearman shown in caption",
       x="Annual PRECTOT (mm) — NASA POWER 2023", y="Density (points km⁻²)") +
  theme(legend.position="bottom")
# annotate Spearman
if (exists("cor_res")) {
  p1 <- p1 + annotate("text", x=min(scatter_df$prectot_sum), y=max(scatter_df$density),
                      label=sprintf("Spearman ρ=%.2f, p=%.3f", cor_res$estimate, cor_res$p.value),
                      hjust=0, vjust=1, size=3.5)
}
ggsave("results/figures/density_vs_rainfall.png", p1, width=7, height=5, dpi=300)
cat("Wrote results/figures/density_vs_rainfall.png\n")

# Fig 5: Correlation heatmap (nasa vars + density) — city level not LGA level: use city means?
# For illustration use scatter_df numeric columns
if (nrow(scatter_df) >= 5) {
  mat <- scatter_df %>% select(density, prectot_sum, t2m_mean, rh2m_mean) %>% cor(method="spearman", use="complete.obs")
  # long format for ggplot
  mat_long <- as.data.frame(as.table(mat))
  names(mat_long) <- c("Var1","Var2","cor")
  p2 <- ggplot(mat_long, aes(x=Var1, y=Var2, fill=cor)) +
    geom_tile(color="white") +
    geom_text(aes(label=sprintf("%.2f", cor)), size=3.5) +
    scale_fill_gradient2(low="#4575b4", mid="white", high="#d73027", midpoint=0, limits=c(-1,1), name="Spearman ρ") +
    theme_minimal(base_size=11) +
    labs(title="Correlation matrix — density and climate (39 LGAs)", x="", y="") +
    theme(axis.text.x=element_text(angle=30, hjust=1))
  ggsave("results/figures/climate_correlation.png", p2, width=6, height=5, dpi=300)
  cat("Wrote results/figures/climate_correlation.png\n")
}

# Fig 6: Density by city (box/violin for LGAs with points)
# Use only LGAs with points
p3 <- ggplot(scatter_df, aes(x=reorder(NAME_1, density, median), y=density, fill=NAME_1)) +
  geom_boxplot(alpha=0.7, outlier.shape=NA) +
  geom_jitter(width=0.15, size=2, alpha=0.8) +
  scale_fill_brewer(palette="Set1", guide="none") +
  theme_minimal(base_size=11) +
  labs(title="Density distribution by state (LGAs with ≥1 point)",
       x="State (GADM NAME_1)", y="Density (points km⁻²)") +
  coord_flip()
ggsave("results/figures/density_by_state.png", p3, width=6, height=4.5, dpi=300)
cat("Wrote results/figures/density_by_state.png\n")

# Also output table for manuscript Table 4
top10 <- lga_df %>% filter(n>0) %>% arrange(desc(density)) %>% select(GID_2, NAME_2, NAME_1, n, area_km2, density, lisa_quad) %>% head(10)
write_csv(top10, "results/top10_density.csv")
cat("Wrote results/top10_density.csv\n")
print(top10)
cat("04_extra_figs.R done\n")
