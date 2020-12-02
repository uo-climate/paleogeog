# plot paleogeography for a particular time

library(sf)

# read projected shapefiles for basemap
shape_path <- paste(getwd(), "/ne_shp_projected/", sep="")

na_bb_lcc <- st_read(paste(shape_path, "na_bb_lcc/na_bb_lcc.shp", sep=""))
na_grat30_lcc <- st_read(paste(shape_path, "na_grat30_lcc/na_grat30_lcc.shp", sep=""))
na_coast_lcc <- st_read(paste(shape_path, "na_coast_lcc/na_coast_lcc.shp", sep=""))
na_admin0_lcc <- st_read(paste(shape_path, "na_admin0_lcc/na_admin0_lcc.shp", sep=""))
na_admin1_lcc <- st_read(paste(shape_path, "na_admin1_lcc/na_admin1_lcc.shp", sep=""))
na_lrglakes_lcc <- st_read(paste(shape_path, "na_lrglakes_lcc/na_lrglakes_lcc.shp", sep=""))
na_bbline_lcc <- st_cast(st_geometry(na_bb_lcc), "LINESTRING") # convert polygon to line

# read and project, shoreline, proglacial-lake and ice-sheet outlines

# i <- 26
for (i in seq(0, 26, by=1)) {
  
  # set age
  age <-  sprintf("%3.1f", i)
  if ((i) < 10) age <- paste("0", age, sep="")
  title <- paste(age, "ka", sep=" ")
  print(title)
  
  # filenames
  shoreline_path <- paste("../Shorelines/shoreline_ice6g_", age, "ka/", sep="")
  shoreline_shapefile <- paste("shoreline_ice6g_10min_", age, "ka.shp", sep="")
  pglake_path <- paste("../GlacialLakes/pglakes_GSC_", age, "ka/", sep="")
  pglake_shapefile <- paste("pglakes_GSC_", age, "ka.shp", sep="")
  ice_path <- paste("../IceSheets/MergedIceSheets/ice_merged_", age, "ka/", sep="")
  ice_shapefile <- paste("ice_merged_", age, "ka.shp", sep="")

  # shapefiles
  shoreline_sf <- st_read(paste(shoreline_path, shoreline_shapefile, sep=""))
  # plot(st_geometry(shoreline_sf))
  st_crs(shoreline_sf)

  pglake_lcc <- st_read(paste(pglake_path, pglake_shapefile, sep=""))
  # plot(st_geometry(pglake_lcc), col="lightblue")
  st_crs(pglake_lcc)

  ice_lcc <- st_read(paste(ice_path, ice_shapefile, sep=""))
  # plot(st_geometry(ice_lcc), col="pink", add=TRUE)
  st_crs(ice_lcc)

  # transform shapefiles to Lambert projection

  # get CRS
  lcc_crs <- st_crs(pglake_lcc)
  lcc_crs

  # do projections
  shoreline_lcc <- st_transform(shoreline_sf, crs = st_crs(lcc_crs))
  # pglake_lcc <- st_transform(pglake_lcc, crs = st_crs(lcc_crs))
  ice_lcc <- st_transform(ice_lcc, crs = st_crs(lcc_crs))

  # plot projected shapefiles
  png_file <- paste("pngs/NorthAmerica/na_", age, "_ka.png", sep="")
  png(file = png_file, width=1200, height= 600)

  plot(st_geometry(na_bb_lcc), col="white", border="black", lwd=2)
  plot(st_geometry(na_grat30_lcc), col="gray50", add=TRUE)
  plot(st_geometry(na_coast_lcc), col="gray80", add=TRUE)
  plot(st_geometry(na_admin0_lcc), border="gray80", add=TRUE)
  plot(st_geometry(na_admin1_lcc), border="gray80", add=TRUE)
  plot(st_geometry(na_lrglakes_lcc), border="gray80", add=TRUE)

  plot(st_geometry(st_crop(shoreline_lcc, na_bb_lcc)), col="black", lwd=1.5, add=TRUE)
  plot(st_geometry(pglake_lcc), col="lightblue", add=TRUE)
  plot(st_geometry(st_crop(ice_lcc, na_bb_lcc)), col="plum1", add=TRUE)
  plot(st_geometry(na_bbline_lcc), col="black", lwd=2, add=TRUE)

  text(-3600000, -3000000, pos=1, cex=2.0, title)

  dev.off()

}
