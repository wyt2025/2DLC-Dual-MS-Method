
# 加载必要的R包
library(readxl)
library(broom)
library(dplyr)
library(writexl)

# 从Excel文件中读取数据
data <- read_excel("Path/Binary logistic regression-input-demo.xlsx")

# 确保BMI列是因子类型，因为这是一个二元结果变量
data$BMI <- as.factor(data$BMI)

# 设定因变量和混杂因素
outcome <- "BMI"
confounders <- c("gender", "age")

# 获取自变量列表，排除因变量和混杂因素
predictors <- setdiff(names(data), c(outcome, confounders))

# 初始化一个列表来存储结果
results <- list()

# 依次对每个自变量进行逻辑回归，并排除混杂因素
for (var in predictors) {
  # 构建公式
  formula <- as.formula(paste(outcome, "~", var, "+", paste(confounders, collapse = " + ")))
  
  # 执行逻辑回归
  model <- glm(formula, data = data, family = binomial())
  
  # 整理回归结果，计算OR值和95%置信区间
  result <- tidy(model, exponentiate = TRUE, conf.int = TRUE)
  
  # 将结果存储到列表中
  results[[var]] <- result
}

# 将结果写入Excel文件
write_xlsx(results, "Path/Binary logistic regression-output1-demo.xlsx")

# 初始化一个列表来存储显著的变量结果
significant_results <- list()

# 遍历所有自变量的回归结果
for (var in predictors) {
  # 获取当前自变量的回归结果
  var_result <- results[[var]]
  
  # 过滤出预测变量的行（排除截距）
  var_term <- which(var_result$term == var)
  
  # 检查预测变量的p值是否小于0.05
  if (length(var_term) > 0 && var_result$p.value[var_term] < 0.05) {
    # 如果p值小于0.05，将结果添加到significant_results列表中
    significant_results[[var]] <- var_result[var_term, ]
  }
}

# 如果存在显著的预测变量，将它们的结果写入Excel文件
if (length(significant_results) > 0) {
  significant_df <- do.call(rbind, significant_results)
  write_xlsx(significant_df, "Path/Binary logistic regression-output2-demo.xlsx")
}
warnings()
  