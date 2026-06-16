################################################################################
# Confidentialise files
# 
################################################################################

## User parameters -------------------------------------------------------- ----

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/in_progress_settings.RDS")

## Load settings ---------------------------------------------------------- ----

settings = readRDS(settings_file)

required_settings = c("control_file_path", "confidentialise_sheet", "raw_summary_file", "conf_summary_file")
for(setting in required_settings){
  stopifnot(setting %in% names(settings))
  assign(setting, settings[[setting]])
}

## Load and run ----------------------------------------------------------- ----

# read
tbl = read.csv(raw_summary_file)
# round
tbl = IDIr::run_confidential(control_file_path, confidentialise_sheet, tbl)
# write
write.csv(tbl, conf_summary_file, row.names = FALSE)

status = "Successful completion"

## All completed successfully --------------------------------------------- ----

no_assembly_failures = status == "Successful completion"
stopifnot(no_assembly_failures)
