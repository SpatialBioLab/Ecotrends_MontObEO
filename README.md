## Run Montobeo models using ecotrends

In this document you can find the code blocks and files needed to run <a href="https://montobeo.wordpress.com/">MontObEO</a> models using **ecotrends**.

Ecotrends is an R package for computing a time series of ecological niche models, using species occurrence data and environmental variables to map temporal trends in environmental suitability. You can see more information on the <a href="https://github.com/AMBarbosa/ecotrends">package's github page</a>.


### Installation

You can (re)install ecotrends from GitHub and then load it:

```
# devtools::install_github("AMBarbosa/ecotrends")  # run if you don't have the latest version!

library(ecotrends)
```

### Regions for modelling

In MontObEO, the maxent classifier was trained in the region of Montesinho Natural Park (MNP) but the results were projected to the Montesinho/Nogueira Protection Area. Thus, two vector files were used:
- <a href="https://drive.google.com/uc?export=download&id=1uuUxtpfjJlTDW4gPKLpz101U6L1yh8cz">pnm.gpkg</a> - with MNP limits
- <a href="https://drive.google.com/uc?export=download&id=1HhLo7iJdTVH259e66YIArJokbyGWQgzP">pnm_n_grid_limit.gpkg</a> - with Montesinho/Nogueira limits (1km cell grid used on the project)

You can download both files by clicking on each of the designations above, place them in your working directory and load them:

```
# specify a folder as the working directory
setwd('C:/...')

# load regions
montesinho <- terra::vect('./pnm.gpkg')
monteNog <- terra::vect('./pnm_n_grid_limit.gpkg')
plot(montesinho)
plot(monteNog)
```

### Species presence coordinates

You will need some species presence coordinates, then you can download the vector file with the <a href="https://drive.google.com/uc?export=download&id=1ohSr_InDlzXThOP3GuJrV5B14aYqv73I">species occurrences</a> modeled in MontObEO.

After loading the file you can filter the species you want to model:

```
# load species occurrences
allOccurr <- terra::vect('./species_modelling_2024_07_15.gpkg')

# filter Cervus_elaphus
species_occ <- allOccurr[which(allOccurr$Species == 'Cervus_elaphus'),]

# extract subset with only coordinate columns
occ_coords <- species_occ[ , c("x3763", "y3763")]

plot(monteNog); points(occ_coords)
```

### Predictors variables

In montobeo, the annual averages of six MODIS variables were used (annual mean aggregated over a grid of 1km cells):
- EVI	- Enhanced Vegetation Index
- SR - Surface Reflectance
- LST day -	Day Land Surface Temperature
- LST night -	Night Land Surface Temperature
- AAB	- Area Annually Burned
- TSF	- Time Since Fire

Since the periodicity is annual, a raster image is required for each year with six bands corresponding to the variables. You can download a zip file with the 23 images of <a href="https://drive.google.com/uc?export=download&id=1PcnfVH89t09LbvTYY2exqGor9JQbZSu4">predictor variables</a> used in Montobeo corresponding to the years 2001 to 2023.

After loading the files, it is necessary to do some processing to adjust the band names to those required by the package (see R help for the getModels function):

```

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
```

### Ecological niche models

We can now compute yearly ecological niche models with these occurrences and variables in the MNP region, optionally saving the results to a file:

```
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
```


### Model predictions

Let's now calculate the model predictions for each year, extrapolating them to the Montesinho/Nogueira region, optionally exporting the results to a file:

```
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
```

### Model performance

You can evaluate the fit of these predictions with the getPerformance function:

```
par(mfrow = c(2, 2))
perf <- ecotrends::getPerformance(rasts = preds,
                                  mods = mods,
                                  plot = FALSE)
head(perf)
```

### Habitat suitability trends

Finally, let's use the getTrend function to get the slope and significance of a linear (monotonic) temporal trend in suitability in each pixel, optionally providing the occurrence coordinates so that the results are restricted to the pixels that overlap them:

```
trend <- ecotrends::getTrend(rasts = preds,
                             occs = occ_coords,
                             alpha = 1,# p-value threshold
                             full = FALSE, # só SenSlope = FALSE
                             #file = "outputs/ecotrends_slope_Cervus_2001_2023"
                             )

plot(trend, col = hcl.colors(100, "spectral"))
```
