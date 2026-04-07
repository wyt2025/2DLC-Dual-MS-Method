


library(tidyverse)   # 数据处理与操作
library(broom)       # 提取模型结果
library(openxlsx)    # 读写Excel文件


input_file <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Binary logistic regression-input.xlsx"  # 输入Excel文件路径
output_file <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Binary logistic regression-output.xlsx"  # 输出结果路径


output_dir <- dirname(output_file)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  cat("已自动创建输出目录：", output_dir, "\n")
}


tryCatch({
  # 查看Excel中的工作表
  sheet_names <- getSheetNames(input_file)
  cat("Excel文件包含的工作表：", paste(sheet_names, collapse = ", "), "\n")
  
 
  data <- read.xlsx(
    xlsxFile = input_file,
    sheet = 1,                  # 工作表索引或名称（如"Sheet1"）
    na.strings = c("", "NA"),   # 定义缺失值标识
    skipEmptyRows = TRUE,       # 跳过空行
    detectDates = FALSE         # 不自动检测日期
  )
  

  cat("\n成功读取数据：\n")
  cat("样本量：", nrow(data), "行\n")
  cat("变量数：", ncol(data), "列\n")
  cat("前10个变量名称：", paste(head(names(data), 10), collapse = ", "), "...\n\n")
  
}, error = function(e) {
  stop("数据读取失败：", e$message, "\n请检查文件路径是否正确或文件是否被占用")
})


cat("数据结构预览：\n")
str(data)


if ("gender" %in% names(data)) {
  data$gender <- as.factor(data$gender)
  cat("\n已将性别变量转换为因子类型\n")
}


outcome_check <- function(data, var) {
  if (!var %in% names(data)) return(FALSE)
  length(unique(na.omit(data[[var]]))) == 2
}


perform_adjusted_logistic <- function(data, outcome_var, predictors, confounders) {
  required_vars <- c(outcome_var, predictors, confounders)
  missing_vars <- setdiff(required_vars, names(data))
  if (length(missing_vars) > 0) {
    stop("数据中缺少以下变量：", paste(missing_vars, collapse = ", "))
  }
  
  if (!outcome_check(data, outcome_var)) {
    stop("结局变量", outcome_var, "不是二分类变量，请检查数据")
  }
  
  analysis_data <- data %>%
    select(all_of(required_vars)) %>%
    drop_na()
  
  cat("\n去除缺失值后有效样本量：", nrow(analysis_data), "\n")
  if (nrow(analysis_data) < 50) {
    warning("样本量较小（<50），结果可能不稳定")
  }
  
  # 循环分析每个自变量
  results <- map_dfr(predictors, function(pred) {
    # 每分析10个变量显示一次进度
    if (which(predictors == pred) %% 10 == 0) {
      cat("已完成", which(predictors == pred), "个变量分析...\n")
    }
    

    formula_str <- paste(outcome_var, "~", pred, "+", paste(confounders, collapse = " + "))
    model_formula <- as.formula(formula_str)
    

    model <- glm(model_formula, data = analysis_data, family = binomial(link = "logit"))
    

    tidy_model <- tidy(model, conf.int = TRUE) %>%
      filter(term == pred) %>%
      mutate(
        predictor = pred,
        or = exp(estimate),
        or_low = exp(conf.low),
        or_high = exp(conf.high)
      ) %>%
      select(
        predictor,
        coefficient = estimate,
        or,
        or_95ci_low = or_low,
        or_95ci_high = or_high,
        p_value = p.value
      )
    
    return(tidy_model)
  })
  

  results <- results %>%
    mutate(fdr_p_value = p.adjust(p_value, method = "BY")) %>%
    arrange(fdr_p_value)  # 按FDR值排序
  
  return(results)
}

outcome_var <- "disease_status"  # 结局变量名称（请修改为你的实际变量名）
predictors <- paste0("predictor", 1:88)  # 自动生成predictor1到predictor47
confounders <- c("gender", "age", "bmi")  # 校正的混杂因素


cat("\n分析参数设置：\n")
cat("结局变量：", outcome_var, "\n")
cat("自变量数量：", length(predictors), "个（从", predictors[1], "到", predictors[88], "）\n")
cat("校正的混杂因素：", paste(confounders, collapse = ", "), "\n")


cat("\n开始执行逻辑回归分析（共47个自变量）...\n")
analysis_results <- perform_adjusted_logistic(
  data = data,
  outcome_var = outcome_var,
  predictors = predictors,
  confounders = confounders
)


cat("\n分析完成！结果预览（前10行）：\n")
print(head(analysis_results, 10))


write.xlsx(
  x = analysis_results,
  file = output_file,
  sheetName = "47个自变量校正结果",
  rowNames = FALSE,
  append = FALSE,
  overwrite = TRUE
)

cat("\n完整结果已保存至：", normalizePath(output_file), "\n")
