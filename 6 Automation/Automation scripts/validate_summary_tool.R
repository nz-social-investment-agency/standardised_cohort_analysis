################################################################################
# Minimal script to validate the Summary tool
# 
################################################################################

## User parameters -------------------------------------------------------- ----

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Execution/in_progress_settings.RDS")

## Load settings ---------------------------------------------------------- ----

settings = readRDS(settings_file)

required_settings = c("control_file_path", "summary_sheet", "summary_master_table", "db_connection_string", "raw_summary_file")
for(setting in required_settings){
  stopifnot(setting %in% names(settings))
  assign(setting, settings[[setting]])
}

## Database connection ---------------------------------------------------- ----

db_connection = DBI::dbConnect(odbc::odbc(), .connection_string = db_connection_string)
remote_master_table = dplyr::tbl(db_connection, ADAPT:::sql2id(summary_master_table))

## Validate summary tool -------------------------------------------------- ----

control_file = ADAPT::load_control_file(
  path_and_file_name = control_file_path,
  sheet = summary_sheet
)

is_valid_summary_control_file = ADAPT::validate_summary_control_file(
  control_file = control_file,
  tbl = remote_master_table,
  save_file = raw_summary_file
)

## All completed successfully --------------------------------------------- ----

DBI::dbDisconnect(db_connection)
stopifnot(is_valid_summary_control_file)
