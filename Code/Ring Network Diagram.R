

library(tidygraph)
library(ggraph)
library(tidyverse)


edges = read_csv("Path/edges.csv")
nodes = read_csv("Path/nodes.csv")


# 构建graph对象用于画图
country_graph = tbl_graph(nodes = nodes, edges = edges)
country_graph


# 配色
pal = c("#0174BE", "#BC7FCD", "#347928", "#e28006",
        "#8e0180", "#a24f20", "#073966", "#e28006")
##作图

#使用ggraph作图，传入上面构建的graph对象，设置布局方式及是否环形显示
ggraph(country_graph,layout = 'dendrogram',circular = TRUE) +
  
  
# 画网络图的边  
  geom_edge_diagonal(aes(color=node1.node_branch),
                     alpha=1, linewidth=0.1) +   
# 画网络图d节点                      
  geom_node_point(aes(size=population, color=node_branch),
                  alpha=0.35) +     
##文字标注  
  geom_node_text(aes(x = x*1.07, y = y*1.07, 
  label=node_name, angle=node_angle(x, y),
filter=leaf,color=node_branch),
size=2,hjust='outward')+ 
  geom_node_text(aes(label=node_name,
                     filter = !leaf,
                     color=node_branch),
                 fontface="bold",size=3.5)+
  scale_size(range = c(2, 25)) +
  scale_color_manual(values = pal) +
  scale_edge_color_manual(values = pal) +
  scale_x_continuous(limits = c(-1.9, 1.9)) +
  scale_y_continuous(limits = c(-1.4, 1.4)) +
  coord_fixed() +
  theme_void() +
  theme(legend.position = "none",
        plot.background = element_rect(fill = "white", color = "white"))