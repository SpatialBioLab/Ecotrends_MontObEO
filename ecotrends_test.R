
setwd('C:/Users/panad/Documents/FCUP/MontObEO/ecotrends_package')

library(terra)

# regions
montesinho <- terra::vect('C:/Users/panad/Documents/FCUP/MontObEO/ecotrends_package/pnm.gpkg')
monteNog <- terra::vect('C:/Users/panad/Documents/FCUP/MontObEO/ecotrends_package/pnm_n_grid_limit.gpkg')
#plot(montesinho)
#plot(monteNog)

#___________________

# load shapefile (.shp)
allOccurr <- terra::vect('C:/Users/panad/Documents/FCUP/MontObEO/Modelacao_FASE_3/shp/species_modelling_2024_07_15.shp')
#filtrar Cervus_elaphus 'Pelophylax_perezi'
species_occ <- allOccurr[which(allOccurr$Species == 'Cervus_elaphus'),]

#___________________

# load cervus occurrences
#species_occ <- terra::vect('C:/Users/panad/Documents/FCUP/MontObEO/ecotrends_package/Cervus_elaphus_pnm.gpkg')

#__________________

# subset só colunas das coordenadas
occ_coords <- species_occ[ , c("x3763", "y3763")]

#head(occ_coords)
#plot(occ_coords)
#plot(monteNog); points(occ_coords)


#-----------------------------------
####### predictor vars ###########

# geoTiff GEE por ano com 6 predictors
input_dir <- "C:/Users/panad/Documents/FCUP/MontObEO/ecotrends_package/rasters_vars"
# Listar arquivos GeoTiff na pasta
tif_files <- list.files(input_dir, pattern = "\\.tif$", full.names = TRUE)

# lista para rasters
raster_list <- list()

# Iterar sobre cada GeoTiff
for (tif in tif_files) {
  
  # Extrair o ano do nome do ficheiro
  year <- sub(".*_(\\d{4})\\.tif$", "\\1", basename(tif))
  
  # Carregar GeoTiff como um objeto SpatRaster
  r <- rast(tif)
  
  #retirar 
  #r <- subset(raster_data, 2:6)
  
  # adicionar year ao nome das bandas
  names(r) <- paste0(names(r), "_", year)
  # Adicionar raster à lista
  raster_list <- c(raster_list, r)
}


# Combinar todos os rasters num único SpatRaster
vars <- do.call(c, raster_list)

# Substituir "LST_Day" por "LSTd" nos nomes das bandas
names(vars) <- sub("LST_Day", "LSTd", names(vars))
# Substituir "LST_Night" por "LSTn" nos nomes das bandas
names(vars) <- sub("LST_Night", "LSTn", names(vars))

#names(vars)
plot(vars[[1:8]])

####### compute yearly ecological niche models ###########

library(ecotrends)

mods <- ecotrends::getModels(occs = occ_coords, 
                        rasts = vars,
                        region = montesinho,
                        collin = FALSE, # verificar Correlat, VIF predictors
                        maxcor = 0.75,
                        maxvif = 5,
                        classes = "default", 
                        regmult = 1, 
                        nreps = 10, # quantidade réplicas
                        test = 0.3, # proporção de test points
                        #file = "outputs/models_0reps"
                        )


####### compute the model predictions ###########

preds <- ecotrends::getPredictions(rasts = vars, 
                                   mods = mods, 
                                   region = monteNog,
                                   type = "cloglog",
                                   clamp = TRUE,
                                   #file = "outputs/predictions_0reps_3"
                                   )

#names(preds)
plot(preds[[3]], range = c(0, 1))

# map the mean prediction across replicates per year

preds_mean <- terra::rast(lapply(preds, terra::app, "mean"))
plot(preds_mean)

#writeRaster(preds_mean, filename = "predictions_cervus", filetype = "GTiff", overwrite = TRUE)


####### evaluate the fit of predictions ###########


par(mfrow = c(2, 2))

perf <- ecotrends::getPerformance(rasts = preds,
                                  mods = mods,
                                  plot = FALSE)

head(perf)
perf
####### check for a linear (monotonic) temporal trend ###########

trend <- ecotrends::getTrend(rasts = preds,
                             #occs = occ_coords,
                             alpha = 5,
                             full = FALSE, # só SenSlope = FALSE
                             #file = "outputs/Ecotrends_slope_Cervus_2013_2023"
                             )

plot(trend, 
     col = hcl.colors(100, "spectral"))

writeRaster(trend, filename = "Significant_Trends_Cervus_2001_23.tif", filetype = "GTiff", overwrite = TRUE)


#____________________________________________
############# install packages ################

devtools::install_github("AMBarbosa/ecotrends")
8

install.packages("modEvA", repos="http://R-Forge.R-project.org")

install.packages("fuzzySim", repos="http://R-Forge.R-project.org")

