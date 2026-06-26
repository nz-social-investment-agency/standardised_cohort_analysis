################################################################################
# Minimal script to initialise new cohort or new refresh
# 
# Required inputs
# > COHORT
# > REFRESH
# > REBUILD_TEMPLATES
# > OVERWRITE_COHORT
# > SPECIFY_TEMPLATE
# > BASE_FOLDER
# If running this file manually, you will need to set these
# Avoid setting these in this code as it prevents correct launcher execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("COHORT"))
stopifnot(exists("REFRESH"))
stopifnot(exists("REBUILD_TEMPLATES"))
stopifnot(exists("OVERWRITE_COHORT"))
stopifnot(exists("BASE_FOLDER"))

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

## Handle specified templates --------------------------------------------- ----

template_list = list(
  # control files
  control_file_pipeline = "control_file - pipeline.xlsx",
  control_file_current_state = "control_file - current_state.xlsx",
  control_file_time_series = "control_file - time_series.xlsx",
  control_file_match_comparison = "control_file - matching_comparison.xlsx",
  control_file_match_forecast = "control_file - matching_forecast.xlsx",
  # user templates
  user_template_client = "user_template_client.sql",
  user_template_target = "user_template_target.sql",
  user_template_possible_client_match = "user_template_possible_client_matches.sql",
  user_template_possible_target_match = "user_template_possible_target_matches.sql",
  user_template_genpop = "user_template_genpop.sql",
  # automation templates
  initialise_current_state = "initialise_current_state_master_table.sql",
  initialise_time_series = "initialise_time_series_master_table.sql",
  initialise_match_comparison = "initialise_matching_comparison_master_table.sql",
  initialise_match_forecast = "initialise_matching_forecast_master_table.sql",
  compress_current_state = "compression_current_state_master_table.sql",
  compress_time_series = "compression_time_series_master_table.sql",
  compress_match_comparison = "compression_matching_comparison_master_table.sql",
  compress_match_forecast = "compression_matching_forecast_master_table.sql",
  tidy_current_state = "tidy_current_state_master_table.sql",
  tidy_time_series = "tidy_time_series_master_table.sql",
  remove_cohort_refresh = "remove_cohort_refresh.sql"
)

# if alternative templates specified
if(exists("SPECIFY_TEMPLATE") && is.list(SPECIFY_TEMPLATE)){
  # override default templates with matching templates
  for(template in names(SPECIFY_TEMPLATE)){
    if(template %in% names(template_list)){
      template_list[[template]] = SPECIFY_TEMPLATE[[template]]
    }
  }
}

## Base validations ------------------------------------------------------- ----

stopifnot(is.character("COHORT"))
stopifnot(grepl("[0-9]{6}", as.character(REFRESH)))
stopifnot(REBUILD_TEMPLATES %in% c(TRUE, FALSE))
stopifnot(OVERWRITE_COHORT %in% c(TRUE, FALSE))
stopifnot(exists("OVERWRITE_COHORT"))
stopifnot(dir.exists(BASE_FOLDER))

stopifnot(DBI::dbCanConnect(odbc::odbc(), .connection_string = db_connection_string))

req_dirs = c(
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

for(this_file in template_list){
  subfolder = ifelse(grepl("^control_file", this_file), "Control files", "SQL templates")
  this_path = file.path(BASE_FOLDER, "6 Automation", subfolder, this_file)
  stopifnot(file.exists(this_path))
}

## Ensure required packages are available --------------------------------- ----

stopifnot("ADAPT" %in% installed.packages())

## Expand summary --------------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Expand compact summary"))

control_file_path = file.path(BASE_FOLDER, "6 Automation", "Control files", template_list$control_file_current_state)
wb = openxlsx2::wb_load(control_file_path)

summary = openxlsx2::wb_to_df(wb, "summary")
column_names = c("eth_maori","eth_pacific","eth_asian","eth_MELAA","eth_other","eth_european")
expanded_summary = ADAPT::expand_compact_summary_groups(summary, column_names = column_names)

wb = openxlsx2::wb_clean_sheet(wb, "expanded_summary", styles = FALSE)
wb = openxlsx2::wb_add_data(wb, "expanded_summary", x = expanded_summary, na.strings = "")

openxlsx2::wb_save(wb, control_file_path)

## Backup control file to CSV --------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Backup control files to CSV"))

folder_control_files = file.path(BASE_FOLDER, "6 Automation", "Control files")
backup_output_folder = file.path(BASE_FOLDER, "6 Automation", "Control file CSV backups")

backup_control_file = function(file, sheet){
  df = openxlsx2::read_xlsx(file.path(folder_control_files, file), sheet = sheet)
  out_file = glue::glue("{tools::file_path_sans_ext(file)} - {sheet}.csv")
  out_file = file.path(backup_output_folder, out_file)
  write.csv(df, out_file, row.names = FALSE, na = "")  
}

backup_control_file(template_list$control_file_pipeline, "pipeline")
backup_control_file(template_list$control_file_current_state, "assembly")
backup_control_file(template_list$control_file_current_state, "summary")
backup_control_file(template_list$control_file_current_state, "expanded_summary")
backup_control_file(template_list$control_file_current_state, "conf_RR3")
backup_control_file(template_list$control_file_time_series, "assembly")
backup_control_file(template_list$control_file_time_series, "summary")
backup_control_file(template_list$control_file_time_series, "conf_RR3")
backup_control_file(template_list$control_file_match_comparison, "assembly")
backup_control_file(template_list$control_file_match_forecast, "assembly")

## Create required folders ------------------------------------------------ ----

ADAPT::run_time_inform_user(glue::glue("Creating folders in '2 Analysis'"))

folder_cohort = file.path(BASE_FOLDER, "2 Analysis", COHORT, REFRESH)
folder_output = file.path(folder_cohort, "Output")
folder_execution = file.path(folder_cohort, "Execution")

dir.create(folder_cohort, showWarnings = FALSE, recursive = TRUE)
dir.create(folder_output, showWarnings = FALSE, recursive = TRUE)
dir.create(folder_execution, showWarnings = FALSE, recursive = TRUE)
Sys.sleep(1)

## Copy required files ---------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Copying files to '2 Analysis'"))

#### control file help function ----

copy_control_files = function(template, to, overwrite = REBUILD_TEMPLATES){
  
  from = file.path(BASE_FOLDER, "6 Automation", "Control files")
  from = file.path(from, template_list[[template]])
  
  out_file = basename(tools::file_path_sans_ext(from))
  out_file = glue::glue("{out_file} - {COHORT}_{REFRESH}.xlsx")
  out_file = file.path(to, out_file)
  
  if(file.exists(out_file) & !overwrite){
    return(invisible("file already exists"))
  }
  
  # source file
  wb = openxlsx2::wb_load(from)
  
  # glue pipeline sheet if exists
  if("pipeline" %in% openxlsx2::wb_get_sheet_names(wb)){
    # modify contents
    df = openxlsx2::wb_to_df(wb, "pipeline")
    are_na = is.na(df$FOLDER)
    df$FOLDER = sapply(df$FOLDER, glue::glue)
    df$FOLDER[are_na] = NA
    df$FILE = sapply(df$FILE, glue::glue)
    # write
    wb = openxlsx2::wb_clean_sheet(wb, "pipeline", styles = FALSE)
    wb = openxlsx2::wb_add_data(wb, "pipeline", x = df, na.strings = "")
  }
  
  # glue assembly sheet if exists
  if("assembly" %in% openxlsx2::wb_get_sheet_names(wb)){
    # modify contents
    df = openxlsx2::wb_to_df(wb, "assembly")
    are_na = is.na(df$measure_table)
    df$measure_table = sapply(df$measure_table, glue::glue)
    df$measure_table[are_na] = NA
    # write
    wb = openxlsx2::wb_clean_sheet(wb, "assembly", styles = FALSE)
    wb = openxlsx2::wb_add_data(wb, "assembly", x = df, na.strings = "")
  }
  
  # write file out
  openxlsx2::wb_save(wb, out_file, overwrite = overwrite)
  return(invisible(out_file))
}

#### control files ----

copy_control_files("control_file_pipeline", folder_execution)
copy_control_files("control_file_current_state", folder_execution)
copy_control_files("control_file_time_series", folder_execution)
copy_control_files("control_file_match_comparison", folder_execution)
copy_control_files("control_file_match_forecast", folder_execution)

#### SQL helper function ----

copy_SQL_files = function(template, to, overwrite){
  
  from = file.path(BASE_FOLDER, "6 Automation", "SQL templates")
  from = file.path(from, template_list[[template]])
  
  out_file = basename(tools::file_path_sans_ext(from))
  out_file = glue::glue("{out_file} - {COHORT}_{REFRESH}.sql")
  out_file = gsub("user_template_", "", out_file, fixed = TRUE)
  out_file = file.path(to, out_file)
  
  if(file.exists(out_file) & !overwrite){
    return(invisible("file already exists"))
  }
  
  template = paste(readLines(from),collapse = '\n')
  template = glue::glue(template)
  
  write(template, file = out_file)
  return(invisible(out_file))
}

#### SQL templates ----

copy_SQL_files("initialise_current_state", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("initialise_time_series", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("initialise_match_comparison", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("initialise_match_forecast", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("compress_current_state", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("compress_time_series", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("compress_match_comparison", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("compress_match_forecast", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("tidy_current_state", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("tidy_time_series", folder_execution, REBUILD_TEMPLATES)
copy_SQL_files("remove_cohort_refresh", folder_execution, REBUILD_TEMPLATES)

copy_SQL_files("user_template_client", folder_cohort, OVERWRITE_COHORT)
copy_SQL_files("user_template_target", folder_cohort, OVERWRITE_COHORT)
copy_SQL_files("user_template_possible_client_match", folder_cohort, OVERWRITE_COHORT)
copy_SQL_files("user_template_possible_target_match", folder_cohort, OVERWRITE_COHORT)
copy_SQL_files("user_template_genpop", folder_cohort, OVERWRITE_COHORT)

## Conclude --------------------------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Initialised {COHORT} - {REFRESH}"))
