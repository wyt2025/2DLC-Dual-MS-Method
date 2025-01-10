

library(tidyverse)
library(RColorBrewer)

source("D:/Work/R数据可视化VIP文档(2024)/解压文件/R绘制旭日图展示化合物分类-20240123/pie_donut-离子对.R")

data_vector <- c("One-MRM-transition Positive 33", 
                 "Two-MRM-transition Positive 451", "One-MRM-transition Negative 38", "Two-MRM-transition Negative 76"
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



