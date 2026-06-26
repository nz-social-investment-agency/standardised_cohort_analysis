control_file_path = "/mnt/DataLab/MAA/MAA2026-04/Cohorts pipeline - solo/2 Analysis/TSI/202603/Execution/control_file - current_state - TSI_202603.xlsx"

wb = openxlsx2::wb_load(control_file_path)

summary = openxlsx2::wb_to_df(wb, "summary")
column_names = c("eth_maori","eth_pacific","eth_asian","eth_MELAA","eth_other","eth_european")
expanded_summary = ADAPT::expand_compact_summary_groups(summary, column_names = column_names)

wb = openxlsx2::wb_clean_sheet(wb, "expanded_summary", styles = FALSE)
wb = openxlsx2::wb_add_data(wb, "expanded_summary", x = expanded_summary, na.strings = "")

openxlsx2::wb_save(wb, control_file_path)

