################################################################################
# Minimal script to validate the Assembly tool
# 
################################################################################

## User parameters -------------------------------------------------------- ----

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Execution/in_progress_settings.RDS")

## Load settings ---------------------------------------------------------- ----

settings = readRDS(settings_file)

required_settings = c("control_file_path", "assembly_sheet", "assembly_master_table", "db_connection_string")
for(setting in required_settings){
  stopifnot(setting %in% names(settings))
  assign(setting, settings[[setting]])
}

## Database connection ---------------------------------------------------- ----

db_connection = DBI::dbConnect(odbc::odbc(), .connection_string = db_connection_string)

## Validate assembly tool ------------------------------------------------- ----

control_file = ADAPT::load_control_file(
  path_and_file_name = control_file_path,
  sheet = assembly_sheet
)

is_valid_assembly_control_file = ADAPT::validate_assembly_control_file(
  control_file = control_file,
  db_connection = db_connection,
  master_table = assembly_master_table
)

## All completed successfully --------------------------------------------- ----

DBI::dbDisconnect(db_connection)
stopifnot(is_valid_assembly_control_file)
