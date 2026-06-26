################################################################################
# Minimal script to execute the Assembly tool
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

## Run assembly tool ------------------------------------------------------ ----

result_df = ADAPT::run_assembly(
  control_file = control_file_path,
  sheet = assembly_sheet,
  db_connection = db_connection,
  master_table = assembly_master_table
)

## All completed successfully --------------------------------------------- ----

DBI::dbDisconnect(db_connection)
no_assembly_failures = all(result_df$status == "Successful completion")
stopifnot(no_assembly_failures)
