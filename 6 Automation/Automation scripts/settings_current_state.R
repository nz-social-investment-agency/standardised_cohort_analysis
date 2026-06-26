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
# > REFRESH
# If running this file manually, you will need to set these.
# Avoid setting these in this code as it prevents correct pipeline execution.
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
phase = "current state"
control_file_path = "{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Execution/control_file - current_state - {COHORT}_{REFRESH}.xlsx"

# assembly
assembly_sheet = "assembly"
assembly_master_table = "[{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]"

# summary
summary_sheet = "expanded_summary"
summary_master_table = "[IDI_UserCode].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]"

# confidentialise & submission
confidentialise_sheet = "conf_RR3"
raw_summary_file = "{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Output/{COHORT}_current_state.csv"
conf_summary_file = "{BASE_FOLDER}/2 Analysis/{COHORT}/{REFRESH}/Output/{COHORT}_current_state_conf.csv"

raw_for_submission_file = "{BASE_FOLDER}/4 For submission/RAW {toupper(COHORT)}_current_state {REFRESH}.csv"
conf_for_submission_file = "{BASE_FOLDER}/4 For submission/CONF {toupper(COHORT)}_current_state {REFRESH}.csv"

# metadata
client_table = "[{PROJECT_DB}.[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]"

## write out settings ----------------------------------------------------- ----

settings = list(
  # universal
  phase = phase,
  control_file_path = glue::glue(control_file_path),
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
