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
stopifnot(exists("REFRESH"))

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Execution/in_progress_settings.RDS")

## load project settings -------------------------------------------------- ----

settings = readRDS(file.path(BASE_FOLDER, "6 Automation", "pipeline_settings.RDS"))

PREFIX = settings$PREFIX
PROJECT_DB = settings$PROJECT_DB
PROJECT_SCHEMA = settings$PROJECT_SCHEMA
db_connection_string = settings$db_connection_string

## inputs ----------------------------------------------------------------- ----

# universal
phase = "matching forecast"
control_file_path = "{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Execution/control_file - matching_forecast - {COHORT}_{REFRESH}.xlsx"

# assembly
assembly_sheet = "assembly"
assembly_master_table = "[{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matching_master_table_{REFRESH}]"

# matching
matching_results = "[{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matched_uids_{REFRESH}]"
exact_match_cols = c("age_ref_date")

## write out settings ----------------------------------------------------- ----

settings = list(
  # universal
  phase = phase,
  control_file_path = glue::glue(control_file_path),
  db_connection_string = db_connection_string,
  # assembly
  assembly_sheet = glue::glue(assembly_sheet),
  assembly_master_table = glue::glue(assembly_master_table),
  # matching
  matching_results = glue::glue(matching_results),
  exact_match_cols = exact_match_cols # no glue required
)

saveRDS(settings, glue::glue(settings_file))
