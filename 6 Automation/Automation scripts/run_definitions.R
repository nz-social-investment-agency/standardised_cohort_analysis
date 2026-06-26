################################################################################
# Minimal script to execute the pipeline for running all definitions
# 
# Required inputs
# > BASE_FOLDER
# > REFRESH
# > REBUILD_TEMPLATES
# > delay_minutes
# > log_file
# If running this file manually, you will need to set these at the console
# Avoid setting these in this code as it prevents correct launcher execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("REFRESH"))
stopifnot(exists("REBUILD_TEMPLATES"))
stopifnot(exists("delay_minutes"))
stopifnot(exists("log_file"))

## Load settings ---------------------------------------------------------- ----

settings_script = file.path(BASE_FOLDER, "6 Automation", "pipeline_constants.R")
source(settings_script, local = new.env())
settings_saved = file.path(BASE_FOLDER, "6 Automation", "pipeline_settings.RDS")
global_settings = readRDS(settings_saved)

PREFIX = global_settings$PREFIX
PROJECT_DB = global_settings$PROJECT_DB
PROJECT_SCHEMA = global_settings$PROJECT_SCHEMA
db_connection_string = global_settings$db_connection_string
SQL_FOLDER = global_settings$SQL_FOLDER

## Base validations ------------------------------------------------------- ----

stopifnot(is.numeric(REFRESH))
stopifnot(dir.exists(BASE_FOLDER))
stopifnot(REBUILD_TEMPLATES %in% c(TRUE, FALSE))
stopifnot(is.numeric(delay_minutes))
stopifnot(is.na(log_file) | is.character(log_file))

stopifnot(DBI::dbCanConnect(odbc::odbc(), .connection_string = db_connection_string))

req_dirs = c(
  "1 Definitions",
  "1 Definitions/Execution",
  glue::glue("1 Definitions/{REFRESH}"),
  "2 Analysis",
  "4 For submission",
  "6 Automation/Automation scripts",
  "6 Automation/Control files",
  "6 Automation/Mappings",
  "6 Automation/SQL templates",
  "6 Automation/Control file CSV backups"
)
for(rd in req_dirs){
  stopifnot(dir.exists(file.path(BASE_FOLDER, rd)))
}

## Ensure required packages are available --------------------------------- ----

stopifnot("ADAPT" %in% installed.packages())

## File paths ------------------------------------------------------------- ----

pipeline_template = file.path(BASE_FOLDER, "6 Automation", "Control files", "control_file - definitions.xlsx")
pipeline_file = file.path(BASE_FOLDER, "1 Definitions", "Execution", "control_file - definitions_pipeline - {REFRESH}.xlsx")
pipeline_file = glue::glue(pipeline_file)
pipeline_csv_backup = file.path(BASE_FOLDER, "6 Automation", "Control file CSV backups", "control_file - definitions - pipeline.csv")

sink_file = file.path(BASE_FOLDER, "1 Definitions", "Execution", log_file)
sink_file = glue::glue(sink_file)

remove_definitions_template = file.path(BASE_FOLDER, "6 Automation", "SQL templates", "remove_refresh_definitions.sql")
remove_definitions_file = file.path(BASE_FOLDER, "1 Definitions", "Execution", "remove_definitions - {REFRESH}.sql")
remove_definitions_file = glue::glue(remove_definitions_file)

## Backup control file to CSV --------------------------------------------- ----

df = openxlsx2::read_xlsx(pipeline_template, "pipeline")
write.csv(df, pipeline_csv_backup, row.names = FALSE, na = "")

## Copy files ------------------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Setup refresh-specific definitions pipeline"))

## pipeline

if(REBUILD_TEMPLATES || !file.exists(pipeline_file)){
  # source file
  wb = openxlsx2::wb_load(pipeline_template)
  
  # modify contents
  df = openxlsx2::wb_to_df(wb, "pipeline")
  
  are_na = is.na(df$FOLDER)
  df$FOLDER = sapply(df$FOLDER, glue::glue)
  df$FOLDER[are_na] = NA
  
  # write
  wb = openxlsx2::wb_clean_sheet(wb, "pipeline", styles = FALSE)
  wb = openxlsx2::wb_add_data(wb, "pipeline", x = df, na.strings = "")
  openxlsx2::wb_save(wb, pipeline_file)
}

## remove_definitions

if(REBUILD_TEMPLATES || !file.exists(remove_definitions_file)){
  template = paste(readLines(remove_definitions_template),collapse = '\n')
  template = glue::glue(template)
  write(template, file = remove_definitions_file)
}

## Validate pipeline ------------------------------------------------------ ----

ADAPT::run_time_inform_user(glue::glue("Validating definitions pipeline"))

pipeline_file = file.path(BASE_FOLDER, "1 Definitions", "Execution", "control_file - definitions_pipeline - {REFRESH}.xlsx")
pipeline_file = glue::glue(pipeline_file)
control_file = ADAPT::load_control_file(pipeline_file, "pipeline")

is_valid = ADAPT::validate_pipeline_control_file(
  control_file = control_file,
  db_connection_string = global_settings$db_connection_string,
  injection_sql = list(
    "$(REFRESH)" = REFRESH,
    "$(PROJECT_DB)" = global_settings$PROJECT_DB,
    "$(PROJECT_SCHEMA)" = global_settings$PROJECT_SCHEMA,
    "$(SQL_FOLDER)" = global_settings$SQL_FOLDER
  )
)

stopifnot(is_valid)

## Run pipeline ----------------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Executing definitions pipeline"))

# execute, capturing messages
status = tryCatch({
  ADAPT::run_pipeline(
    control_file = pipeline_file,
    sheet = "pipeline",
    db_connection_string = global_settings$db_connection_string,
    delay_minutes = delay_minutes,
    sink_file = ifelse(is.na(log_file), NULL, sink_file),
    injection_sql = list(
      "$(REFRESH)" = REFRESH,
      "$(PROJECT_DB)" = global_settings$PROJECT_DB,
      "$(PROJECT_SCHEMA)" = global_settings$PROJECT_SCHEMA,
      "$(SQL_FOLDER)" = global_settings$SQL_FOLDER
    )
  )
})

## Conclude --------------------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Definitions complete"))
