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

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/in_progress_settings.RDS")

## inputs ----------------------------------------------------------------- ----

phase = "matching comparison"

# universal
control_file_path = "{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/control_file - matching_comparison.xlsx"
sql_folder = "{BASE_FOLDER}/1 Definitions"

# assembly
assembly_sheet = "assembly"
assembly_master_table = "[SIA_Sandpit].[DL-MAA2023-46].[{COHORT}_comparison_matching_master_table]"

# matching
matching_results = "[SIA_Sandpit].[DL-MAA2023-46].[{COHORT}_comparison_matched_uids]"
exact_match_cols = c("age_ref_date", "reference_date")

## database connection ---------------------------------------------------- ----

# database connection - requires SQL Server in environment
db_connection_string = "DRIVER=ODBC Driver 18 for SQL Server; Trusted_Connection=Yes; TrustServerCertificate=Yes;"
db_connection_string = paste(db_connection_string, "DATABASE=IDI_Clean_202410;")
db_connection_string = paste(db_connection_string, "SERVER=PRTPRDSQL36, 1433")

## copy control file if it does not exist --------------------------------- ----

control_file_path = glue::glue(control_file_path)
if(!file.exists(control_file_path)){
  
  control_file_source = file.path(BASE_FOLDER, "6 Automation", "Control files", "control_file - matching_comparison.xlsx")
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
  # matching
  matching_results = glue::glue(matching_results),
  exact_match_cols = exact_match_cols # no glue required
)

saveRDS(settings, glue::glue(settings_file))
