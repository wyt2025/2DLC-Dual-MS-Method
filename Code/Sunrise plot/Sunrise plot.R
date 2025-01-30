
library(tidyverse)
library(RColorBrewer)
library(webr)

source("Path/pie_donut.R")

data_vector <- c("Fungicides Pesticides 117", 
                 "Herbicides Pesticides 113", "Insecticides Pesticides 106", "Others Pesticides 5",
                 "Antimicrobial-agents Drugs 52", "Adrenal-receptor-drugs Drugs 26",  
                 "Hormones Drugs 21", "Anti-inflammatory-drugs Drugs 14", 
                 "Antihistamines Drugs 11", "Additives Drugs 6", 
                 "Others Drugs 54", "PFASs Pollutants 20", 
                 "Dyes Pollutants 13", "UV-Absorbers Pollutants 13", "Phenols Pollutants 7", 
                 "Organic-flame-retardants Pollutants 5", "Others Pollutants 15"
                 )


split_data <- lapply(data_vector, function(x) strsplit(x, " ", fixed = TRUE)[[1]])

df <- data.frame(
  Category = sapply(split_data, `[`, 1),
  Exposome = sapply(split_data, `[`, 2),
  n = sapply(split_data, `[`, 3)) %>% 
  mutate(n=as.numeric(n))


pie_donut_full(df,aes(Exposome,Category,count=n),ratioByGroup=F,
               showRatioDonut=F,
               showRatioThreshold = 0.001,showRatioPie=F,
               explodeDonut=TRUE,maxx=1.9,
               palette_name = "Paired")



