# inputs and outputs
input_file = "project/folder/subfolder/file.xlsx"
output_file = "project/folder/subfolder/file.xlsx"

# column names for * expansion (e.g. 'eth_*')
column_names = c("eth_maori","eth_pacific","eth_asian","eth_MELAA","eth_other","eth_european")

# read compact file
compact_df = openxlsx2::read_xlsx(filepath, sheet = "summary")
# expand
expanded_df = IDIr::expand_compact_summary_groups(compact_df, column_names = column_names)
# write expanded file
openxlsx2::write_xlsx(expanded_df, output_file ,sheet = "summary", rowNames = FALSE)
