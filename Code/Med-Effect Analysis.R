library(mediation)
library(openxlsx)
library(dplyr)

set.seed(123)

# 设置路径
xlsx.path <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Med-Effect Analysis-input.xlsx"
output.path <- "Path/2DLC-Dual MS Method—code_WYT/code-2026/Example/Med-Effect Analysis-output.xlsx"

# 读取数据
YL.data <- openxlsx::read.xlsx(xlsxFile = xlsx.path, sheet = 1)

# 识别暴露物和代谢物列
predictor_cols <- grep("^predictor", colnames(YL.data), value = TRUE)
metabolite_cols <- grep("^meta", colnames(YL.data), value = TRUE)

# 创建Excel工作簿
wb <- createWorkbook()

# 循环每个暴露物
for(predictor in predictor_cols) {
  # 创建数据框存储当前暴露物的所有结果
  results_df <- data.frame()
  
  # 循环每个代谢物
  for(metabolite in metabolite_cols) {
    tryCatch({
      # 构建中介变量模型（代谢物 ~ 暴露物 + 混杂因素）
      model_mediator <- lm(
        as.formula(paste(metabolite, "~", predictor, "+ gender + age + BMI")),
        data = YL.data
      )
      
      # 构建结果模型（结局 ~ 代谢物 + 暴露物 + 混杂因素）
      model_outcome <- glm(
        as.formula(paste("group ~", metabolite, "+", predictor, "+ gender + age + BMI")),
        data = YL.data,
        family = binomial()
      )
      
      # 进行中介分析
      med_result <- mediate(
        model_mediator, 
        model_outcome, 
        treat = predictor, 
        mediator = metabolite,
        boot = TRUE, 
        sims = 500
      )
      
      # 提取结果
      summary_med <- summary(med_result)
      
      # 整理结果 - 重点关注ACME、ADE、Total Effect和Prop. Mediated
      result_row <- data.frame(
        Metabolite = metabolite,
        ACME_Estimate = summary_med$d.avg,
        ACME_CI_Lower = summary_med$d.avg.ci[1],
        ACME_CI_Upper = summary_med$d.avg.ci[2],
        ACME_p = summary_med$d.avg.p,
        ADE_Estimate = summary_med$z.avg,
        ADE_CI_Lower = summary_med$z.avg.ci[1],
        ADE_CI_Upper = summary_med$z.avg.ci[2],
        ADE_p = summary_med$z.avg.p,
        Total_Effect_Estimate = summary_med$tau.coef,
        Total_Effect_CI_Lower = summary_med$tau.ci[1],
        Total_Effect_CI_Upper = summary_med$tau.ci[2],
        Total_Effect_p = summary_med$tau.p,
        Prop_Mediated_Estimate = summary_med$n.avg,
        Prop_Mediated_CI_Lower = summary_med$n.avg.ci[1],
        Prop_Mediated_CI_Upper = summary_med$n.avg.ci[2],
        Prop_Mediated_p = summary_med$n.avg.p
      )
      
      # 添加到结果数据框
      results_df <- rbind(results_df, result_row)
      
    }, error = function(e) {
      # 如果分析出错，记录错误信息
      result_row <- data.frame(
        Metabolite = metabolite,
        Error = paste("Analysis failed:", e$message)
      )
      # 确保列数一致
      for(col in setdiff(names(results_df), names(result_row))) {
        result_row[[col]] <- NA
      }
      results_df <- rbind(results_df, result_row)
    })
  }
  
  # 为当前暴露物创建工作表
  sheet_name <- substr(predictor, 1, min(31, nchar(predictor))) # Excel工作表名称限制31字符
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet = sheet_name, x = results_df)
}

# 保存Excel工作簿
saveWorkbook(wb, output.path, overwrite = TRUE)

print("分析完成，结果已保存到Excel文件。")