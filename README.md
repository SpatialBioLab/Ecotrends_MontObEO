# Run MontObEO models using ecotrends

Ecotrends is an R package for computing a time series of ecological niche models, using species occurrence data and environmental variables to map temporal trends in environmental suitability. You can see more information on the  <a href="https://github.com/AMBarbosa/ecotrends">package's github page</a>.

Here you will find the code blocks and files needed to model species as performed in the <a href="https://montobeo.wordpress.com/">MontObEO project</a>.

## Installation

You can (re)install ecotrends from GitHub and then load it:

```
# devtools::install_github("AMBarbosa/ecotrends")  # run if you don't have the latest version!

library(ecotrends)
```

## Regions for modelling

In MontObEO, the maxent classifier was trained in the region of Montesinho Natural Park (MNP) but the results were projected to the Montesinho/Nogueira Protection Area. Thus, two vector files were used:
- pnm.gpkg - with MNP limits
- pnm_n_grid_limit.gpkg - with Montesinho/Nogueira limits (1km cell grid used on the project)
You can download both files by clicking on the designation, place them in your working directory, and then load them:

```
# specify a folder as the working directory
setwd('C:/Users/userFolder')

# load regions
montesinho <- terra::vect('./pnm.gpkg')
monteNog <- terra::vect('./pnm_n_grid_limit.gpkg')
plot(montesinho)
plot(monteNog)

```



