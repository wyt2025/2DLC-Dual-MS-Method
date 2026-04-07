# 加载必要的库
library(tidyverse)   # 数据处理
library(broom)       # 整理回归结果
library(openxlsx)    # 导出Excel文件

# --------------------------
# 1. 设置文件路径（请根据实际情况修改）
# --------------------------
input_file_path <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Multiple linear regression-input.xlsx"
output_file_path <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Multiple linear regression-output.xlsx"

# --------------------------
# 2. 导入数据
# --------------------------
if (tools::file_ext(input_file_path) == "csv") {
  df <- read.csv(input_file_path, stringsAsFactors = FALSE, na.strings = c("", "NA"))
} else if (tools::file_ext(input_file_path) == "xlsx") {
  df <- read.xlsx(input_file_path)
} else {
  stop("不支持的文件格式，请使用CSV或Excel文件")
}

# 查看数据基本信息
cat("数据导入成功！共", nrow(df), "行，", ncol(df), "列\n")

# --------------------------
# 3. 定义核心变量（自动识别y开头的因变量）
# --------------------------
# 自动识别所有以"y"开头的因变量
outcome_vars <- grep("^y", names(df), value = TRUE)
if (length(outcome_vars) == 0) {
  stop("未找到以'y'开头的因变量，请检查变量命名规则")
}
cat("自动识别到", length(outcome_vars), "个因变量（y开头）：", paste(outcome_vars, collapse = ", "), "\n")

exposure_prefix <- "predictor"      # 暴露因素统一前缀
confounders <- c("gender", "age", "bmi")  # 混杂因素

# 自动识别暴露因素
exposure_vars <- grep(paste0("^", exposure_prefix), names(df), value = TRUE)
if (length(exposure_vars) == 0) {
  stop("未找到符合命名规则的暴露因素，请检查前缀是否正确")
}
cat("自动识别到", length(exposure_vars), "个暴露因素：", paste(exposure_vars, collapse = ", "), "\n")

# 检查所有因变量和混杂因素是否存在
all_required_vars <- unique(c(outcome_vars, confounders))
missing_vars <- setdiff(all_required_vars, names(df))
if (length(missing_vars) > 0) {
  stop("数据中缺少必要变量：", paste(missing_vars, collapse = ", "))
}

# --------------------------
# 4. 初始化工作簿（关键修改：使用工作簿对象管理多sheet）
# --------------------------
wb <- createWorkbook()  # 创建新的Excel工作簿对象
# 创建输出目录（如果不存在）
if (!dir.exists(dirname(output_file_path))) {
  dir.create(dirname(output_file_path), recursive = TRUE)
}

# --------------------------
# 5. 循环处理每个因变量
# --------------------------
for (outcome_var in outcome_vars) {
  cat("\n===== 开始处理因变量：", outcome_var, " =====\n")
  
  # 处理缺失值
  df_clean <- df %>% 
    select(all_of(c(outcome_var, exposure_vars, confounders))) %>% 
    drop_na()
  cat("处理缺失值后，有效样本数：", nrow(df_clean), "\n")
  
  # 批量回归分析
  results_list <- list()
  p_values <- numeric(length(exposure_vars))
  names(p_values) <- exposure_vars
  
  for (exposure in exposure_vars) {
    # 构建回归公式
    formula_str <- paste(outcome_var, "~", exposure, "+", paste(confounders, collapse = " + "))
    model_formula <- as.formula(formula_str)
    
    # 执行线性回归
    model <- lm(model_formula, data = df_clean)
    
    # 提取结果
    model_result <- tidy(model, conf.int = TRUE) %>%
      filter(term == exposure) %>%
      mutate(
        exposure = exposure,
        outcome = outcome_var,
        r_squared = summary(model)$r.squared,
        adj_r_squared = summary(model)$adj.r.squared
      ) %>%
      select(outcome, exposure, term, estimate, std.error, conf.low, conf.high, 
             statistic, p.value, r_squared, adj_r_squared)
    
    results_list[[exposure]] <- model_result
    p_values[exposure] <- model_result$p.value
  }
  
  # 计算FDR
  fdr_values <- p.adjust(p_values, method = "fdr")
  fdr_df <- data.frame(
    exposure = names(fdr_values),
    fdr = fdr_values,
    stringsAsFactors = FALSE
  )
  
  # 整理结果
  final_results <- bind_rows(results_list) %>%
    left_join(fdr_df, by = "exposure") %>%
    rename(
      因变量 = outcome,
      暴露因素 = exposure,
      变量 = term,
      回归系数 = estimate,
      标准误 = std.error,
      CI95下限 = conf.low,
      CI95上限 = conf.high,
      t统计量 = statistic,
      P值 = p.value,
      FDR = fdr,
      R平方 = r_squared,
      调整后R平方 = adj_r_squared
    ) %>%
    select(因变量, 暴露因素, 变量, 回归系数, 标准误, CI95下限, CI95上限,
           t统计量, P值, FDR, R平方, 调整后R平方)
  
  # 关键修改：向工作簿添加sheet（而非直接写入文件）
  addWorksheet(wb, sheetName = outcome_var)  # 添加新sheet
  writeData(wb, sheet = outcome_var, x = final_results, rowNames = FALSE)  # 写入数据
  
  cat("因变量", outcome_var, "分析完成，已添加到sheet：", outcome_var, "\n")
  print(head(final_results, 3))
}

# --------------------------
# 6. 最后统一保存工作簿（关键修改）
# --------------------------
saveWorkbook(wb, file = output_file_path, overwrite = TRUE)

cat("\n所有因变量分析完成！结果已保存至：", output_file_path, "\n")
