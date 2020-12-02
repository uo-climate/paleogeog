# download and project Natural Earth shapefiles
# https://www.naturalearthdata.com

library(rnaturalearth)
library(sf)

shapefile_dir <- "ne_shp_source"

# download and save various shapefile components to use as a basemap
gl_bb_sf <- ne_download(scale=50, type="wgs84_bounding_box", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_grat30_sf <- ne_download(scale=50, type="graticules_30", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_grat05_sf <- ne_download(scale=50, type="graticules_5", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_coast_sf <- ne_download(scale=50, type="coastline", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_admin0_sf <- ne_download(scale=50, type="admin_0_map_units", category="cultural", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_admin1_sf <- ne_download(scale=50, type="admin_1_states_provinces", category="cultural", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_lakes_sf <- ne_download(scale=50, type="lakes", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")
gl_lakes_historic_sf <- ne_download(scale=50, type="lakes_historic", category="physical", destdir=shapefile_dir, load=TRUE, returnclass="sf")

# get large lakes only
gl_lrglakes_sf <- gl_lakes_sf[as.numeric(gl_lakes_sf$scalerank) <= 2 ,]
# drop the present-day Aral Sea
gl_lrglakes_sf <- gl_lrglakes_sf[gl_lrglakes_sf$name != "Aral Sea", ]
# combine with historical lakes, restoring historical Aral Sea
gl_lrglakes_sf <- st_union(gl_lrglakes_sf, gl_lakes_historic_sf)
plot(st_geometry(gl_lrglakes_sf), col="lightblue")

# plot everything, in an appropriate order
plot(st_geometry(gl_bb_sf), col="lightcyan", border="black", lwd=2)
plot(st_geometry(gl_grat05_sf), col="gray50", add=TRUE)
plot(st_geometry(gl_coast_sf), col="black", add=TRUE)
plot(st_geometry(gl_admin0_sf), col="gray70", add=TRUE)
plot(st_geometry(gl_admin1_sf), col="gray70", add=TRUE)
plot(st_geometry(gl_lrglakes_sf), col="lightblue", add=TRUE)


# read an GSC ice-sheet outline file to get CRS info
ice_path <- paste("../IceSheets/NorthAmericaIceSheets/ice_GSC_26.0ka/", sep="")
ice_shapefile <- paste("ice_GSC_26.0ka.shp", sep="")
ice_lcc <- st_read(paste(ice_path, ice_shapefile, sep=""))
plot(st_geometry(ice_lcc), col="pink")
lcc_crs <- st_crs(ice_lcc,)
lcc_crs
ice_bb <- st_bbox(ice_lcc)
ice_bb

# read an merged ice-sheet outline file 
ice_path <- paste("../IceSheets/MergedIceSheets/ice_merged_26.0ka/", sep="")
ice_shapefile <- paste("ice_merged_26.0ka.shp", sep="")
ice_merged_lcc <- st_read(paste(ice_path, ice_shapefile, sep=""))
plot(st_geometry(ice_merged_lcc), col="pink")

# read an merged ice-sheet outline file 
ice_path <- paste("../IceSheets/MergedIceSheets/ice_merged_26.0ka/", sep="")
ice_shapefile <- paste("ice_merged_26.0ka.shp", sep="")
ice_merged_lcc <- st_read(paste(ice_path, ice_shapefile, sep=""))
plot(st_geometry(ice_merged_lcc), col="pink")

# read an LGM shoreline file file 
shoreline_path <- paste("../Shorelines/shoreline_ice6g_26.0ka/", sep="")
shoreline_shapefile <- paste("shoreline_ice6g_10min_26.0ka.shp", sep="")
lgm_shoreline_sf <- st_read(paste(shoreline_path, shoreline_shapefile, sep=""))
plot(st_geometry(lgm_shoreline_sf), col="blue")

# transform shapefiles to Lambert Conformal Conic projection

# do projections
ice_merged_lcc <- st_transform(ice_merged_lcc, crs = st_crs(lcc_crs))
lgm_shoreline_lcc <- st_transform(lgm_shoreline_sf, crs = st_crs(lcc_crs))
na_grat30_lcc <- st_transform(gl_grat30_sf, crs = st_crs(lcc_crs))
na_grat05_lcc <- st_transform(gl_grat05_sf, crs = st_crs(lcc_crs))
na_coast_lcc <- st_transform(gl_coast_sf, crs = st_crs(lcc_crs))
na_admin0_lcc <- st_transform(gl_admin0_sf, crs = st_crs(lcc_crs))
na_admin1_lcc <- st_transform(gl_admin1_sf, crs = st_crs(lcc_crs))
na_lrglakes_lcc <- st_transform(gl_lrglakes_sf, crs = st_crs(lcc_crs))

# new bounding box -- determined by trial and error
na_bb_lcc <- st_make_grid(c(xmin = -4400000, xmax = 3550000, ymax = 4500000, ymin = -3550000), n=1, crs = st_crs(ice_lcc))

# plot projected shapefiles
plot(na_bb_lcc)
plot(st_geometry(ice_merged_lcc), col="lightcyan", border="black", add=TRUE)
plot(st_geometry(lgm_shoreline_lcc, na_bb_lcc), col="blue", add=TRUE)
plot(st_geometry(na_grat30_lcc), col="gray50", add=TRUE)
plot(st_geometry(na_grat05_lcc), col="gray50", add=TRUE)
plot(st_geometry(na_coast_lcc), col="black", add=TRUE)
plot(st_geometry(na_admin0_lcc), col="gray70", add=TRUE)
plot(st_geometry(na_admin1_lcc), col="gray70", add=TRUE)
plot(st_geometry(na_lrglakes_lcc), col="lightblue", add=TRUE)
plot(na_bb_lcc, add=TRUE)

# crop the projected shapefiles to na_bb_lcc)
na_grat30_lcc <- st_crop(na_grat30_lcc, na_bb_lcc)
na_grat05_lcc <- st_crop(na_grat05_lcc, na_bb_lcc)
na_coast_lcc <- st_crop(na_coast_lcc, na_bb_lcc)
na_admin0_lcc <- st_crop(na_admin0_lcc, na_bb_lcc)
na_admin1_lcc <- st_crop(na_admin1_lcc, na_bb_lcc)
na_lrglakes_lcc <- st_crop(na_lrglakes_lcc, na_bb_lcc)


# save the projected shapefiles
# set working directory
shapefile_dir <- "/ne_shp_projected/"
wd <- getwd()
setwd(paste(wd, shapefile_dir, sep=""))

# write the shapefiles
st_write(na_bb_lcc, dsn="na_bb_lcc", driver="ESRI Shapefile")
st_write(na_grat30_lcc, dsn="na_grat30_lcc", driver="ESRI Shapefile")
st_write(na_grat05_lcc, dsn="na_grat05_lcc", driver="ESRI Shapefile")
st_write(na_coast_lcc, dsn="na_coast_lcc", driver="ESRI Shapefile")
st_write(st_geometry(na_admin0_lcc), dsn="na_admin0_lcc", driver="ESRI Shapefile") # geometry only
st_write(st_geometry(na_admin1_lcc), dsn="na_admin1_lcc", driver="ESRI Shapefile") # geometry only
st_write(na_lrglakes_lcc, dsn="na_lrglakes_lcc", driver="ESRI Shapefile")

# restore working directory
setwd(wd) 

# test by reading back in
test_shapefile <- paste(getwd(), shapefile_dir, "/na_coast_lcc/na_coast_lcc.shp", sep="")
test_sf <- st_read(test_shapefile)
plot(st_geometry(test_sf))


