# plot paleogeography for a particular time

library(sf)

# read projected shapefiles for basemap
shape_path <- paste(getwd(), "/ne_shp_projected/", sep="")

gl_bb_rob <- st_read(paste(shape_path, "gl_bb_rob/gl_bb_rob.shp", sep=""))
gl_grat30_rob <- st_read(paste(shape_path, "gl_grat30_rob/gl_grat30_rob.shp", sep=""))
gl_coast_rob <- st_read(paste(shape_path, "gl_coast_rob/gl_coast_rob.shp", sep=""))
gl_admin0_rob <- st_read(paste(shape_path, "gl_admin0_rob/gl_admin0_rob.shp", sep=""))
gl_admin1_rob <- st_read(paste(shape_path, "gl_admin1_rob/gl_admin1_rob.shp", sep=""))
gl_lrglakes_rob <- st_read(paste(shape_path, "gl_lrglakes_rob/gl_lrglakes_rob.shp", sep=""))
gl_bbline_rob <- st_cast(st_geometry(gl_bb_rob), "LINESTRING") # convert polygon to line

# read and project, shoreline, proglacial-lake and ice-sheet outlines

# set age
age <- "14.0"
title <- paste(age, "ka", sep=" ")

# filenames
shoreline_path <- paste("../Shorelines/shoreline_ice6g_", age, "ka/", sep="")
shoreline_shapefile <- paste("shoreline_ice6g_10min_", age, "ka.shp", sep="")
pglake_path <- paste("../GlacialLakes/pglakes_GSC_", age, "ka/", sep="")
pglake_shapefile <- paste("pglakes_GSC_", age, "ka.shp", sep="")
ice_path <- paste("../IceSheets/MergedIceSheets/ice_merged_", age, "ka/", sep="")
ice_shapefile <- paste("ice_merged_", age, "ka.shp", sep="")

# shapefiles
shoreline_sf <- st_read(paste(shoreline_path, shoreline_shapefile, sep=""))
plot(st_geometry(shoreline_sf))
st_crs(shoreline_sf)

pglake_lcc <- st_read(paste(pglake_path, pglake_shapefile, sep=""))
plot(st_geometry(pglake_lcc), col="lightblue")
st_crs(pglake_lcc)

ice_lcc <- st_read(paste(ice_path, ice_shapefile, sep=""))
plot(st_geometry(ice_lcc), col="pink", add=TRUE)
st_crs(ice_lcc)

# transform shapefiles to Robinson projection

# set CRS
robinson_projstring <- "+proj=robin +lon_0=0w"
robinson_projstring

# do projections
shoreline_rob <- st_transform(shoreline_sf, crs = st_crs(robinson_projstring))
pglake_rob <- st_transform(pglake_lcc, crs = st_crs(robinson_projstring))
ice_rob <- st_transform(ice_lcc, crs = st_crs(robinson_projstring))

# plot projected shapefiles
png_file <- paste("pngs/globe/globe_", age, "_ka.png", sep="")
png(file = png_file, width=1200, height= 600)

plot(st_geometry(gl_bb_rob), col="white", border="black", lwd=2) 
plot(st_geometry(gl_grat30_rob), col="gray50", add=TRUE)
plot(st_geometry(gl_coast_rob), col="gray80", add=TRUE)
plot(st_geometry(gl_admin0_rob), border="gray80", add=TRUE)
plot(st_geometry(gl_admin1_rob), border="gray80", add=TRUE)
plot(st_geometry(gl_lrglakes_rob), border="gray80", add=TRUE)

plot(st_geometry(shoreline_rob), col="black", lwd=1.5, add=TRUE)
plot(st_geometry(pglake_rob), col="lightblue", add=TRUE)
plot(st_geometry(ice_rob), col="plum1", add=TRUE)
plot(st_geometry(gl_bbline_rob), col="black", lwd=2, add=TRUE)

text(-14000000, -7700000, pos=1, cex=2.0, title)

dev.off()

