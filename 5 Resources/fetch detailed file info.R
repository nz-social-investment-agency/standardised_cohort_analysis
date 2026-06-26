################################################################################
# Fetch detailed file information
# Simon Anastasiadis
# 2026-04-09
# 
# File systems save detailed information about files including created and
# modified dates, the user who created them, size, and extension.
# 
# When locating files it is sometimes useful to scan an entire directory and
# locate all files that were created by a specific user within a specific time
# frame.
# 
# For example:
# Alice is sick, find what she was working on last week to meet a deadline.
# Bob solved this problem before he finished 2 years ago, where is it saved?
################################################################################

## user parameters -------------------------------------------------------- ----

base_folder = "~/Network-Shares/DataLabNas/MAA/MAA2026-04"

subfolders_to_scan = c(
  "For output"
)

output_csv = "~/Network-Shares/DataLabNas/MAA/MAA2026-04/file_list.csv"

## get info from every project -------------------------------------------- ----

stopifnot("fs" %in% installed.packages())

all_folder_info = list()

for(pp in subfolders_to_scan){
  path = fs::path(base_folder, pp)
  
  all_files = fs::dir_ls(path = path, recurse = TRUE)
  all_files = fs::path_real(all_files)
  
  all_file_info = fs::file_info(all_files)
  all_file_info$project = pp
  all_file_info$ext = fs::path_ext(all_file_info$path)
  
  all_folder_info = c(all_folder_info, list(all_file_info))
}

## combine and output ----------------------------------------------------- ----

if("dplyr" %in% installed.packages()){
  combined_folder_info = dplyr::bind_rows(all_folder_info)
} else {
  combined_folder_info = do.call(rbind, all_folder_info)
}

write.csv(combined_folder_info, output_csv, row.names = FALSE)
