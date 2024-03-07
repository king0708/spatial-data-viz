
# General Packages
library(tidyverse) # data manipulation and plotting 
library(ggplot2)   # plotting and mapping
library(patchwork) # combining maps/plots

# Spatial Packages
library(sf)        # manipulating spatial data
library(ggspatial) # retrieving basemap, adding scale and arrowbar
library(maptiles)  # retrieving basemap
library(terra)     # working with raster data
library(tidyterra) # functions for working with raster

# Data 
library(tigris)  # shapefiles with various administrative boundaries and roads

# read in data from .csv file
site_df <- read_csv("https://knb.ecoinformatics.org/knb/d1/mn/v2/object/urn%3Auuid%3A5d23a3f4-6ed8-47f0-b34e-000f6cfb8313")
ecoreg_sf <- sf::read_sf("data/ca_ecoregion_shape/ca_eco_l4.shp")

states_sf <- tigris::states(progress_bar = FALSE)

site_sf <- site_df %>% 
  st_as_sf(
    coords = c("long", "lat"), # specify where spatial data is; "longitude" is first
    crs    = "EPSG:4326"      # need to tell it what the CRS is
  )

# project site and state lines to ecoreg CRS
states_proj_sf <- st_transform(states_sf, st_crs(ecoreg_sf))
site_proj_sf   <- st_transform(site_sf, st_crs(ecoreg_sf))

ca_proj_sf <- states_proj_sf %>%
  filter(NAME == "California")

site_ca_proj_sf <- site_proj_sf %>% 
  st_filter(ca_proj_sf, .predicate = st_covered_by)

unique(site_ca_proj_sf$state)

site_ecoreg_sf <- st_join(site_ca_proj_sf, ecoreg_sf, join = st_intersects)
# st_intersects is the default

colnames(site_ecoreg_sf)

ggplot(data = ca_proj_sf) +
  geom_sf() 

ggplot() + # don't specify data here since we have multiple data sets to plot
  geom_sf(data = ca_proj_sf) + # must specify "data = " or it will throw an error
  geom_sf(data = ecoreg_sf) + 
  geom_sf(data = site_ca_proj_sf)

ggplot() + # don't specify data here since we have multiple data sets to plot
  geom_sf(data = ca_proj_sf, fill = NA) + # specify no fill
  geom_sf(data = ecoreg_sf, aes(fill = US_L3NAME), color = "grey40") + # like other data you can set fill 
  geom_sf(data = site_ca_proj_sf) +
  scale_fill_discrete(name = "Ecoregion") +
  theme_bw() 

