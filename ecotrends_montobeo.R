
######## install package ########

devtools::install_github("AMBarbosa/ecotrends")


######## Regions for modelling ########

#specify a folder as the working directory
setwd('C:/...')

library(terra)

montesinho <- terra::vect('./pnm.gpkg')
monteNog <- terra::vect('./pnm_n_grid_limit.gpkg')
plot(montesinho)
plot(monteNog)


######## Species presence coordinates ########

# load species occurrences
allOccurr <- terra::vect('./species_modelling_2024_07_15.gpkg')

# filter Cervus_elaphus
species_occ <- allOccurr[which(allOccurr$Species == 'Cervus_elaphus'),]

# extract subset with only coordinate columns
occ_coords <- species_occ[ , c("x3763", "y3763")]

plot(monteNog); points(occ_coords)


######## Predictors variables ########

# list tif files in folder where are the images from predictors_vars.zip
raster_dir <- "./pred_vars"
tif_files <- list.files(raster_dir, pattern = "\\.tif$", full.names = TRUE)
r <- terra::rast(tif_files[[1]])


# create empty rasters list
raster_list <- list()

# iterate over each GeoTiff file
for (tif in tif_files) {
  
  # extract year from file name
  year <- sub(".*_(\\d{4})\\.tif$", "\\1", basename(tif))
  
  # load GeoTiff as a SpatRaster object
  r <- rast(tif)
  
  # add year to band name
  names(r) <- paste0(names(r), "_", year)
  
  # add raster to list
  raster_list <- c(raster_list, r)
}

# join all rasters into a single SpatRaster
vars <- do.call(c, raster_list)

# Adjusting LST band names to remove underscore
names(vars) <- sub("LST_Day", "LSTd", names(vars))
names(vars) <- sub("LST_Night", "LSTn", names(vars))


plot(vars[[1:6]])

######## Ecological niche models ########

library(ecotrends)

mods <- ecotrends::getModels(occs = occ_coords, 
                        rasts = vars,
                        region = montesinho,
                        collin = TRUE, # check Correlation and VIF of predictors
                        maxcor = 0.75,
                        maxvif = 5,
                        classes = "default", 
                        regmult = 1,
                        nreps = 10, # number of replicates
                        test = 0.3, # test points proportion
                        #file = "outputs/models"
                        )


####### Model predictions ###########

preds <- ecotrends::getPredictions(rasts = vars, 
                                   mods = mods, 
                                   region = monteNog,
                                   type = "cloglog",
                                   clamp = TRUE,
                                   #file = "outputs/predictions"
                                   )

# compute the mean prediction across replicates per year
preds_mean <- terra::rast(lapply(preds, terra::app, "mean"))
plot(preds_mean[[1:6]], range = c(0, 1))

# export GeoTiff with predictions for all years
writeRaster(preds_mean, filename = "predictions_cervus.tif", filetype = "GTiff", overwrite = TRUE)

######## Model performance ########

par(mfrow = c(2, 2))

perf <- ecotrends::getPerformance(rasts = preds,
                                  mods = mods,
                                  plot = FALSE)

head(perf)


######## Habitat suitability trends ########

trend <- ecotrends::getTrend(rasts = preds,
                             occs = occ_coords, # comment this line if you don't want to limit results to presences
                             alpha = 0.05,# p-value threshold (use 1 to not filter by p-value)
                             full = FALSE, # só SenSlope = FALSE
                             #file = "outputs/ecotrends_slope_Cervus_2001_2023"
                             )

plot(trend, col = hcl.colors(100, "spectral"))

