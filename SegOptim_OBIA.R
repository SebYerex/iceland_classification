#Call in necessary packages
library(SegOptim)
library(raster)
library(randomForest)

## INPUTS ##

#Make path objects
IcelandMain.Path <- "C:/Users/sebas/OneDrive/Desktop/Honours/Summer 2023/Iceland"
IcelandData.Path <- "C:/Users/sebas/OneDrive/Desktop/Honours/IcelandData"
TestData.Path <- "C:/Users/sebas/OneDrive/Desktop/Honours/IcelandData/Day_1/DJI_202307111709_004_Felt2023-400-5/"

#Path to Orfeo Toolbox binaries
##For accessing Orfeo Toolbox algorithims
otbPath <- "C:/OTB-8.1.2-Win64/bin"


#Set working directory
setwd("C:/Users/sebas/Downloads/test_data")




# Path to raster data used for image segmentation
# In SEGM_FEAT directory
inputSegFeat.path <- "./SEGM_FEAT/SegmFeat_WV2_b532.tif"

# Path to training raster data
# [0] Non-invaded areas [1] Acacia dealbata invaded areas
# In TRAIN_AREAS directory
trainData.path <- "./TRAIN_AREAS/TrainAreas.tif"

# Path to raster data used as classification features
# In CLASSIF_FEAT directory
classificationFeatures.path <- c("./CLASSIF_FEAT/ClassifFeat_WV2_NDIs.tif",
                                 "./CLASSIF_FEAT/ClassifFeat_WV2_SpectralBands.tif")



## OUTPUTS ##


## Output file from OTB image segmentation
outSegmRst.path <- "./segmRaster.tif"

# The final output file containing the distribution of the target species
outClassRst.path <- "./WV2_VilarVeiga_AcaciaDealbata_v1.tif"


#OTB segmentation

## Run the segmentation
outSegmRst <- SegOptim::segmentation_OTB_LSMS(
  # Input raster with features/bands to segment
  inputRstPath = inputSegFeat.path,
  # Algorithm params
  SpectralRange = 3.1,
  SpatialRange = 4.5,
  MinSize = 21,
  # Output
  outputSegmRst = outSegmRst.path,
  verbose = TRUE,
  otbBinPath = otbPath,
  lsms_maxiter = 50)


# Check the file paths with outputs
print(outSegmRst)

# Load the segmented raster and plot it
segmRst <- raster(outSegmRst$segm)

plot(segmRst)


## LOAD TRAINING DATA AND CLASSIFICATION FEATURES ##

# Train data
trainDataRst <- raster(trainData.path)

# Classification features
classificationFeatures <- stack(classificationFeatures.path)
# Change the names for each layer
names(classificationFeatures) <- c(paste("NDI_",1:28,sep=""),paste("SpecBand_",1:8,sep=""))


## PREPARE CLASSIFICATION DATASET ##
calData <- SegOptim::prepareCalData(
                          rstSegm = segmRst,
                          trainData = trainDataRst,
                          rstFeatures = classificationFeatures,
                          thresh = 0.5,
                          funs = "mean",
                          minImgSegm = 30,
                          verbose = TRUE)


