################################################################################
# Minimal script to execute the Pipeline tool
# 
# Required inputs
# > BASE_FOLDER
# > COHORT
# > REFRESH
# > delay_minutes
# > log_file
# If running this file manually, you will need to set these at the console
# Avoid setting these in this code as it prevents correct launcher execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("COHORT"))
stopifnot(exists("REFRESH"))
stopifnot(exists("delay_minutes"))

## Handle COHORT ---------------------------------------------------------- ----

stopifnot(is.character(COHORT))
COHORT_list = unlist(strsplit(COHORT, ",", fixed = TRUE))
COHORT_list = trimws(COHORT_list)

## Base validations ------------------------------------------------------- ----

stopifnot(grepl("[0-9]{6}", as.character(REFRESH)))
stopifnot(dir.exists(BASE_FOLDER))
stopifnot(is.numeric(delay_minutes))

req_dirs = c(
  "1 Definitions/{REFRESH}",
  "2 Analysis",
  "2 Analysis/{COHORT}",
  "2 Analysis/{COHORT}/{REFRESH}",
  "2 Analysis/{COHORT}/{REFRESH}/Output",
  "2 Analysis/{COHORT}/{REFRESH}/Execution",
  "4 For submission",
  "6 Automation/Automation scripts",
  "6 Automation/Control files",
  "6 Automation/Mappings"
)

for(COHORT in COHORT_list){
  req_dirs = sapply(req_dirs, glue::glue, USE.NAMES = FALSE)
  for(rd in req_dirs){
    stopifnot(dir.exists(file.path(BASE_FOLDER, rd)))
  }
}

## Load settings ---------------------------------------------------------- ----

settings_script = file.path(BASE_FOLDER, "6 Automation", "pipeline_constants.R")
source(settings_script, local = new.env())
settings_saved = file.path(BASE_FOLDER, "6 Automation", "pipeline_settings.RDS")
global_settings = readRDS(settings_saved)

db_connection_string = global_settings$db_connection_string

## Ensure required packages are available --------------------------------- ----

stopifnot("ADAPT" %in% installed.packages())

## Validate pipeline ------------------------------------------------------ ----

all_pipelines_valid = TRUE

for(COHORT in COHORT_list){
  pipeline_file = glue::glue(file.path(BASE_FOLDER, "2 Analysis", COHORT, REFRESH, "Execution", "control_file - pipeline - {COHORT}_{REFRESH}.xlsx"))
  control_file = ADAPT::load_control_file(pipeline_file, "pipeline")
  
  is_valid = ADAPT::validate_pipeline_control_file(
    control_file = control_file,
    db_connection_string = db_connection_string
  )
  
  if(!is_valid){
    warning("Pipeline for ", COHORT, " is invalid")
  }
  
  all_pipelines_valid = all_pipelines_valid & is_valid
}
stopifnot(all_pipelines_valid)

## Run pipeline ----------------------------------------------------------- ----

# write console log to file (appends to existing file, NA deactivates)
log_file = glue::glue("run_pipeline_log - {REFRESH}.txt")

for(COHORT in COHORT_list){
  pipeline_file = glue::glue(file.path(BASE_FOLDER, "2 Analysis", COHORT, REFRESH, "Execution", "control_file - pipeline - {COHORT}_{REFRESH}.xlsx"))
  sink_file = file.path(BASE_FOLDER, "2 Analysis", COHORT, REFRESH, "Output", log_file)
  
  batch_start = Sys.time()
  msg = glue::glue("Pipeline for {COHORT} exited with error")
  
  # execute, capturing messages
  tryCatch({
    result_df = ADAPT::run_pipeline(
      control_file = pipeline_file,
      sheet = "pipeline",
      db_connection_string = db_connection_string,
      delay_minutes = delay_minutes,
      sink_file = sink_file,
      injection_r = list(
        "COHORT" = COHORT,
        "REFRESH" = REFRESH,
        "BASE_FOLDER" = BASE_FOLDER
      )
    )
    
    # calculate number successes and number attempts
    result_df = dplyr::filter(result_df, batch_start <= .data$start_time)
    if("enabled" %in% colnames(result_df)){
      result_df = dplyr::filter(result_df, .data$enabled == TRUE)
    }
    num_success = sum(result_df$status == "Successful completion")
    msg = glue::glue("Pipeline for {COHORT} finished with {num_success} of {nrow(result_df)} attempted")
  })
  
  ADAPT::run_time_inform_user(msg)
  
  # only first pipeline run has delay
  delay_minutes = 0
}
