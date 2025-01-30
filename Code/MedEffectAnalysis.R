##YL.data test
library(mediation)

set.seed(123)

xlsx.path <- "Path/MedEffect-input-demo.xlsx"
YL.data <- openxlsx::read.xlsx(xlsxFile = xlsx.path, sheet = 1)

sink("Path/MedEffect-output-demo.txt", append=TRUE)

for (i in c(3:45)){
  print(colnames(YL.data)[i])
  
  #构建代谢物和暴露的方程
  eval(parse(text = paste0("b <- lm(", colnames(YL.data)[i], " ~ E_15, data=YL.data)")))
  
  #然后建立结局变量(既可以是某一个临床连续变化的指标，也可以是分类的疾病分组)，中介变量和自变量关系方程
  #由于是二分类变量，即用glm函数构建回归分析，同时加上family = binomial(link=logit)说明
  eval(parse(text = paste0("c <- glm(group ~", colnames(YL.data)[i], "+ E_15, data=YL.data,family = binomial())")))
  
  #中介分析，这个treat相当于是给与的暴露情况，是连续变量
  
  contcont <- mediate(b, c, boot=TRUE, sims=100,
                      treat="E_15", mediator=colnames(YL.data)[i])
                      #treat.value = 1, control.value = 0#)
  
  print(summary(contcont))
  
}

sink()

