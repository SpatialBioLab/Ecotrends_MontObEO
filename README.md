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
- <a href="https://drive.google.com/file/d/1uuUxtpfjJlTDW4gPKLpz101U6L1yh8cz/view?usp=sharing">pnm.gpkg</a> - with MNP limits
- <a href="https://drive.google.com/file/d/1HhLo7iJdTVH259e66YIArJokbyGWQgzP/view?usp=sharing">pnm_n_grid_limit.gpkg</a> - with Montesinho/Nogueira limits (1km cell grid used on the project)


- <a href="https://drive.google.com/uc?export=download&id=1HhLo7iJdTVH259e66YIArJokbyGWQgzP">pnm_n_grid_limit.gpkg</a> - with Montesinho/Nogueira limits (1km cell grid used on the project)



You can download both files by clicking on each of the designations above, place them in your working directory and load them:
```
# specify a folder as the working directory
setwd('C:/Users/userFolder')

# load regions
montesinho <- terra::vect('./pnm.gpkg')
monteNog <- terra::vect('./pnm_n_grid_limit.gpkg')
plot(montesinho)
plot(monteNog)

```

### Species presence coordinates

You will need some species presence coordinates, then you can download the vector file with the <a href="https://drive.google.com/file/d/1ohSr_InDlzXThOP3GuJrV5B14aYqv73I/view?usp=sharing">species occurrences</a> modeled in MontObEO.

After loading the file you can filter the species you want to model:


```
# load shapefile (.shp)
allOccurr <- terra::vect('./????????')

#filter Cervus_elaphus
species_occ <- allOccurr[which(allOccurr$Species == 'Cervus_elaphus'),]

# extract subset with only coordinate columns
occ_coords <- species_occ[ , c("x3763", "y3763")]

plot(monteNog); points(occ_coords)


# faltam figuras e definir espécie
```

### Predictors variables

In montobeo, the annual averages of six MODIS variables were used (annual mean aggregated over a grid of 1km cells):
- EVI	- Enhanced Vegetation Index
- SR - Surface Reflectance
- LST day -	Day Land Surface Temperature
- LST night -	Night Land Surface Temperature
- AAB	- Area Annually Burned
- TSF	- Time Since Fire

Since the periodicity is annual, a raster image is required for each year with six bands corresponding to the variables. You can download a zip file with the 23 images of <a href="https://drive.google.com/file/d/1PcnfVH89t09LbvTYY2exqGor9JQbZSu4/view?usp=sharing">predictor variables</a> used in Montobeo corresponding to the years 2001 to 2023.

After loading the files, it is necessary to do some processing to adjust the band names to those required by the package (see R help for the getModels function):

```

código
imagens

```

### Ecological niche models

We can now compute yearly ecological niche models with these occurrences and variables in the MNP region, optionally saving the results to a file:

```

código
Imagens?

```

### Model predictions

Let's now calculate the model predictions for each year, extrapolating them to the Montesinho/Nogueira region, optionally exporting the results to a file:

```

código
Imagens

```

### Model performance

You can evaluate the fit of these predictions with the getPerformance function:

```

código
Imagens

```

### Habitat suitability trends

Finally, let's use the getTrend function to get the slope and significance of a linear (monotonic) temporal trend in suitability in each pixel, optionally providing the occurrence coordinates so that the results are restricted to the pixels that overlap them:

```

código
Imagens

```
