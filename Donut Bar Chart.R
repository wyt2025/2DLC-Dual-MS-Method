library(tidyverse)
library(ggtext)

df <- read_tsv("D:/Work/R数据可视化VIP文档(2024)/解压文件/NC图表复现环状条形图-20240220/data.tsv") %>% 
  select(geneSymbol,Rho_deplete,med_LFC,type,id) %>% 
  mutate(type=case_match(type,"MGT1 high vs low" ~ "Pestides n=16",
                         "MGT4 high vs low" ~ "Drugs n=8",
                         "PNGT3 high vs low" ~ "Pollutants n=20",
                         .default = type))


adjust_label_angles <- function(df, id_column) {
  nBar <- nrow(df)
  angle <- 90 - 360 * (df[[id_column]] - 0.5) / nBar
  
  df$hjust <- as.numeric(angle < -90)
  df$angle <- (angle + 180) * (angle < -90) + angle * (angle >= -90)
  
  return(df)
}


label_data <- adjust_label_angles(df, "id")


col <- c("#6895D2","#7ABA78","#F3B95F")

ggplot(df) +
  geom_bar(aes(x = id, y = med_LFC,fill=type),
           stat = "identity", position = "dodge",
           show.legend = T,alpha = .9,linewidth = 0.5) +
  coord_polar()+
  scale_y_continuous(limits = c(-4,5.5),expand = c(0,0)) +
  geom_point(data=df,aes(x = id, y = med_LFC,size=Rho_deplete),shape=19,alpha=0.7,show.legend = T,colour = "#81689D")+
  geom_text(data=label_data, 
            aes(x=id, y=med_LFC+0.5, label=geneSymbol, hjust=hjust),
            fontface="bold",
            alpha=1, size=3, angle= label_data$angle, inherit.aes = FALSE )+
  scale_x_continuous(expand = c(0,0))+
  scale_fill_manual(labels = paste("<span style='color:",col,
                                   "'>",unique(df$type),
                                   "</span>"),values = col,
                    name="Exposome")+
  guides(size="none")+
  labs( x=NULL,y=NULL) +
  theme( panel.background = element_blank(),
         plot.background = element_blank(),
         axis.text = element_blank(),
         legend.text = element_markdown(size = 8, face = "bold"),
         legend.title = element_text(vjust = 0.5,hjust=0.5,face="bold"),
         legend.position = c(0.5,0.5),
         panel.grid.major = element_blank(),
         panel.grid.minor = element_blank(),
         axis.ticks = element_blank(),
         plot.margin = margin(0,0,0,0))
