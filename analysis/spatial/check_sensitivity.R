library(sf); library(spdep); library(spatialreg); library(dplyr)
lga <- st_read('results/lga_lisa.gpkg', quiet=TRUE)
nb_q <- poly2nb(lga, queen=TRUE); lw_q <- nb2listw(nb_q, style='W', zero.policy=TRUE)
nb_r <- poly2nb(lga, queen=FALSE); lw_r <- nb2listw(nb_r, style='W', zero.policy=TRUE)
cat('queen\n'); print(moran.test(lga$density, lw_q, zero.policy=TRUE))
cat('rook\n'); print(moran.test(lga$density, lw_r, zero.policy=TRUE))
# Kano excluded
lga_nkano <- lga %>% filter(NAME_1 != 'Kano')
nb_nk <- poly2nb(lga_nkano, queen=TRUE); lw_nk <- nb2listw(nb_nk, style='W', zero.policy=TRUE)
lga_nkano$log_area <- log(lga_nkano$area_km2)
cat('Kano excluded N', nrow(lga_nkano), '\n')
print(moran.test(lga_nkano$density, lw_nk, zero.policy=TRUE))
m0 <- lm(density ~ log_area, data=lga_nkano)
print(summary(m0))
mlag <- lagsarlm(density ~ log_area, data=lga_nkano, listw=lw_nk, zero.policy=TRUE)
print(summary(mlag))
# Climate Kano excluded
library(readr); library(dplyr)
nasa <- read_csv('data/processed/nasa_annual.csv', show_col_types=FALSE); nasa$city <- tolower(nasa$city)
state_to_city <- c('Federal Capital Territory'='abuja','Lagos'='lagos','Kano'='kano','Rivers'='port_harcourt','Gombe'='gombe')
lga$city_key <- state_to_city[lga$NAME_1]
lga <- left_join(lga, nasa, by=c('city_key'='city'))
dat <- lga %>% filter(n>0, !is.na(prectot_sum), NAME_1 != 'Kano')
cat('climate Kano excluded N', nrow(dat), '\n')
if(nrow(dat)>=10){
  m0c <- lm(density ~ log_area + prectot_sum + t2m_mean, data=dat %>% st_drop_geometry())
  print(summary(m0c))
}
