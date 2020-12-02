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
plot(st_geometry(gl_grat30_sf), col="gray50", add=TRUE)
plot(st_geometry(gl_coast_sf), col="black", add=TRUE)
plot(st_geometry(gl_admin0_sf), col="gray70", add=TRUE)
plot(st_geometry(gl_admin1_sf), col="gray70", add=TRUE)
plot(st_geometry(gl_lrglakes_sf), col="lightblue", add=TRUE)

# transform shapefiles to Robinson projection

# set CRS
robinson_projstring <- "+proj=robin +lon_0=0w"
robinson_projstring

# do projections
gl_bb_rob <- st_transform(gl_bb_sf, crs = st_crs(robinson_projstring))
gl_grat30_rob <- st_transform(gl_grat30_sf, crs = st_crs(robinson_projstring))
gl_coast_rob <- st_transform(gl_coast_sf, crs = st_crs(robinson_projstring))
gl_admin0_rob <- st_transform(gl_admin0_sf, crs = st_crs(robinson_projstring))
gl_admin1_rob <- st_transform(gl_admin1_sf, crs = st_crs(robinson_projstring))
gl_lrglakes_rob <- st_transform(gl_lrglakes_sf, crs = st_crs(robinson_projstring))

# plot projected shapefiles
plot(st_geometry(gl_bb_rob), col="lightcyan", border="black", lwd=2)
plot(st_geometry(gl_grat30_rob), col="gray50", add=TRUE)
plot(st_geometry(gl_coast_rob), col="black", add=TRUE)
plot(st_geometry(gl_admin0_rob), col="gray70", add=TRUE)
plot(st_geometry(gl_admin1_rob), col="gray70", add=TRUE)
plot(st_geometry(gl_lrglakes_rob), col="lightblue", add=TRUE)

# save the projected shapefiles
# set working directory
shapefile_dir <- "/ne_shp_projected/"
wd <- getwd()
setwd(paste(wd, shapefile_dir, sep=""))

# write the shapefiles
st_write(gl_bb_rob, dsn="gl_bb_rob", driver="ESRI Shapefile")
st_write(gl_grat30_rob, dsn="gl_grat30_rob", driver="ESRI Shapefile")
st_write(gl_coast_rob, dsn="gl_coast_rob", driver="ESRI Shapefile")
st_write(st_geometry(gl_admin0_rob), dsn="gl_admin0_rob", driver="ESRI Shapefile") # geometry only
st_write(st_geometry(gl_admin1_rob), dsn="gl_admin1_rob", driver="ESRI Shapefile") # geometry only
st_write(gl_lrglakes_rob, dsn="gl_lrglakes_rob", driver="ESRI Shapefile")

# restore working directory
setwd(wd) 

# test by reading back in
test_shapefile <- paste(getwd(), shapefile_dir, "/gl_coast_rob/gl_coast_rob.shp", sep="")
test_sf <- st_read(coast_shapefile)
plot(st_geometry(test_sf))


