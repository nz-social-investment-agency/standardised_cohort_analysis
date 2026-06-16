################################################################################
# Centralised settings for Automation Tools
# 
# Writes RDS file with in-progress settings.
# This file is overwritten by whichever process is currently running.
# 
# By using a single file for settings, all the Automation Scripts can read
# this file for the settings that change between input populations.
# 
# Injection inputs
# > BASE_FOLDER
# > COHORT
# If running this file manually, you will need to set these
# Avoid setting these in this code as it prevents correct pipeline execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("COHORT"))

settings_file = "{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/in_progress_settings.RDS"

## inputs ----------------------------------------------------------------- ----

phase = "time series"

# universal
control_file_path = "{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/control_file - time_series.xlsx"
sql_folder = "{BASE_FOLDER}/1 Definitions"

# assembly
assembly_sheet = "assembly"
assembly_master_table = "[SIA_Sandpit].[DL-MAA2023-46].[{COHORT}_time_series_master_table]"

# summary
summary_sheet = "summary"
summary_master_table = "[IDI_UserCode].[DL-MAA2023-46].[{COHORT}_time_series_master_table]"

# confidentialise & submission
confidentialise_sheet = "conf_RR3"
raw_summary_file = "{BASE_FOLDER}/2 Analysis/{COHORT}/Output/{COHORT}_time_series.csv"
conf_summary_file = "{BASE_FOLDER}/2 Analysis/{COHORT}/Output/{COHORT}_time_series_conf.csv"

raw_for_submission_file = "{BASE_FOLDER}/4 For submission/{toupper(COHORT)}_time_series RAW.csv"
conf_for_submission_file = "{BASE_FOLDER}/4 For submission/{toupper(COHORT)}_time_series CONF.csv"

# metadata
client_table = "[SIA_Sandpit].[DL-MAA2023-46].[{COHORT}_client]"

## database connection ---------------------------------------------------- ----

# database connection - requires SQL Server in environment
db_connection_string = "DRIVER=ODBC Driver 18 for SQL Server; Trusted_Connection=Yes; TrustServerCertificate=Yes;"
db_connection_string = paste(db_connection_string, "DATABASE=IDI_Clean_202410;")
db_connection_string = paste(db_connection_string, "SERVER=PRTPRDSQL36, 1433")

## copy control file if it does not exist --------------------------------- ----

control_file_path = glue::glue(control_file_path)
if(!file.exists(control_file_path)){
  
  control_file_source = file.path(BASE_FOLDER, "6 Automation", "Control files", "control_file - time_series.xlsx")
  file.copy(control_file_source, control_file_path)
  
}

## write out settings ----------------------------------------------------- ----

settings = list(
  phase = phase,
  # universal
  control_file_path = glue::glue(control_file_path),
  sql_folder = glue::glue(sql_folder),
  db_connection_string = db_connection_string,
  # assembly
  assembly_sheet = glue::glue(assembly_sheet),
  assembly_master_table = glue::glue(assembly_master_table),
  # summary
  summary_sheet = glue::glue(summary_sheet),
  summary_master_table = glue::glue(summary_master_table),
  # confidentialise & submission
  confidentialise_sheet = glue::glue(confidentialise_sheet),
  raw_summary_file = glue::glue(raw_summary_file),
  conf_summary_file = glue::glue(conf_summary_file),
  raw_for_submission_file = glue::glue(raw_for_submission_file),
  conf_for_submission_file = glue::glue(conf_for_submission_file),
  # metadata
  client_table = glue::glue(client_table)
)

saveRDS(settings, glue::glue(settings_file))
