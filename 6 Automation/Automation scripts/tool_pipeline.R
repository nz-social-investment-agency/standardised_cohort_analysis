################################################################################
# Minimal script to execute the Pipeline tool
# 
# Required inputs
# > BASE_FOLDER
# > COHORT
# > delay_minutes
# > log_file
# If running this file manually, you will need to set these
# Avoid setting these in this code as it prevents correct launcher execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("COHORT"))
stopifnot(exists("delay_minutes"))
stopifnot(exists("log_file"))

## Base validations ------------------------------------------------------- ----

stopifnot(is.na(COHORT) | is.character(COHORT))
stopifnot(dir.exists(BASE_FOLDER))
stopifnot(is.numeric(delay_minutes))
stopifnot(is.na(log_file) | is.character(log_file))

req_dirs = c(
  "1 Definitions",
  "2 Analysis",
  "4 For submission",
  "6 Automation/Automation scripts",
  "6 Automation/Control files",
  "6 Automation/Mappings"
)
for(rd in req_dirs){
  stopifnot(dir.exists(file.path(BASE_FOLDER, rd)))
}

## Database connection ---------------------------------------------------- ----
# database connection - requires SQL Server in environment

db_connection_string = "DRIVER=ODBC Driver 18 for SQL Server; Trusted_Connection=Yes; TrustServerCertificate=Yes;"
db_connection_string = paste(db_connection_string, "DATABASE=IDI_UserCode;")
db_connection_string = paste(db_connection_string, "SERVER=PRTPRDSQL36, 1433")

## Ensure required packages are available --------------------------------- ----

stopifnot("openxlsx2" %in% installed.packages())
stopifnot("IDIr" %in% installed.packages())

## Handle COHORT ---------------------------------------------------------- ----

if(is.na(COHORT)){
  COHORT = basename(rstudioapi::selectDirectory())
}

if(is.null(COHORT)){
  stop("No directory/cohort selected")
}
COHORT_list = unlist(strsplit(COHORT, ",", fixed = TRUE))
COHORT_list = trimws(COHORT_list)

for(COHORT in COHORT_list){
  cohort_dir = file.path(BASE_FOLDER, "2 Analysis", COHORT)
  stopifnot(dir.exists(cohort_dir))
  
  # create subfolders
  subfolder = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Output")
  if(!dir.exists(subfolder)){ dir.create(subfolder) }
  subfolder = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Execution")
  if(!dir.exists(subfolder)){ dir.create(subfolder) }
  Sys.sleep(2)
  
  # setup pipeline
  pipeline_file = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Execution", "control_file - pipeline.xlsx")
  pipeline_source = file.path(BASE_FOLDER, "6 Automation", "Control files", "control_file - pipeline.xlsx")
  if(!file.exists(pipeline_file)){
    # source file
    wb = openxlsx2::wb_load(pipeline_source)
    # modify contents
    df = openxlsx2::wb_to_df(wb, "pipeline")
    are_na = is.na(df$FOLDER)
    df$FOLDER = sapply(df$FOLDER, glue::glue)
    df$FOLDER[are_na] = NA
    df$FILE = sapply(df$FILE, glue::glue)
    # write
    wb = openxlsx2::wb_clean_sheet(wb, "pipeline", styles = FALSE)
    wb = openxlsx2::wb_add_data(wb, "pipeline", x = df, na.strings = "")
    openxlsx2::wb_save(wb, pipeline_file)
  }
  
}

## Validate pipeline ------------------------------------------------------ ----

all_pipelines_valid = TRUE

for(COHORT in COHORT_list){
  pipeline_file = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Execution", "control_file - pipeline.xlsx")
  control_file = IDIr::load_control_file(pipeline_file, "pipeline")
  
  is_valid = IDIr::validate_pipeline_control_file(
    control_file = control_file,
    db_connection_string = db_connection_string,
    injection_sql = list("$COHORT" = COHORT)
  )
  
  if(!is_valid){
    warning("Pipeline for ", COHORT, " is invalid")
  }
  
  all_pipelines_valid = all_pipelines_valid & is_valid
}
stopifnot(all_pipelines_valid)

## Run pipeline ----------------------------------------------------------- ----

for(COHORT in COHORT_list){
  pipeline_file = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Execution", "control_file - pipeline.xlsx")
  sink_file = file.path(BASE_FOLDER, "2 Analysis", COHORT, "Execution", log_file)
  
  # execute, capturing messages
  status = tryCatch(
    {
      IDIr::run_pipeline(
        control_file = pipeline_file,
        sheet = "pipeline",
        db_connection_string = db_connection_string,
        delay_minutes = delay_minutes,
        sink_file = ifelse(is.na(log_file), NULL, sink_file),
        injection_r = list("COHORT" = COHORT, "BASE_FOLDER" = BASE_FOLDER),
        injection_sql = list("$COHORT" = COHORT)
      )
      "No errors in batch"
    },
    error = function(e){
      msg = paste(e$message, collapse = "\n")
      msg = paste("Stopped with error: ", msg)
      return(msg)
    },
    warning = function(w){
      msg = paste(w$message, collapse = "\n")
      msg = paste("Stopped with warning: ", msg)
      return(msg)
    }
  )
  
  IDIr::run_time_inform_user(glue::glue("{COHORT} complete with message:\n{status}"))
  
  # only first pipeline run has delay
  delay_minutes = 0
}
