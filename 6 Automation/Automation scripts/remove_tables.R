################################################################################
# Minimal script to remove SQL tables and Views created during Pipeline run
# 
# Required inputs
# > BASE_FOLDER
# > COHORT
# > log_file
# > to_remove
# If running this file manually, you will need to set these at the console
# Avoid setting these in this code as it prevents correct launcher execution
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("COHORT"))
stopifnot(exists("to_remove"))

## Base validations ------------------------------------------------------- ----

stopifnot(is.na(COHORT) | is.character(COHORT))
stopifnot(dir.exists(BASE_FOLDER))
stopifnot(is.character(to_remove))

## Database connection ---------------------------------------------------- ----
# database connection - requires SQL Server in environment

db_connection_string = "DRIVER=ODBC Driver 18 for SQL Server; Trusted_Connection=Yes; TrustServerCertificate=Yes;"
db_connection_string = paste(db_connection_string, "DATABASE=IDI_UserCode;")
db_connection_string = paste(db_connection_string, "SERVER=PRTPRDSQL36, 1433")

## Handle COHORT ---------------------------------------------------------- ----

if(is.na(COHORT)){
  COHORT = basename(rstudioapi::selectDirectory(path = BASE_FOLDER))
}

if(is.null(COHORT) | is.na(COHORT)){
  stop("No directory/cohort selected")
}
COHORT_list = unlist(strsplit(COHORT, ",", fixed = TRUE))
COHORT_list = trimws(COHORT_list)

## Process selected cohorts ----------------------------------------------- ----

ADAPT::run_time_inform_user(glue::glue("Removing SQL tables and views begun"))
db_connection = DBI::dbConnect(odbc::odbc(), .connection_string = db_connection_string)

for(COHORT in COHORT_list){
  ADAPT::run_time_inform_user(glue::glue("{COHORT} begun"))
  
  cohort_dir = file.path(BASE_FOLDER, "2 Analysis", COHORT)
  stopifnot(dir.exists(cohort_dir))
  
  # drop each object
  for(sql_object in to_remove){
    sql_object = glue::glue(sql_object)
    
    # is view
    is_view = grepl("^\\[?IDI_UserCode", sql_object)
    
    if(is_view){
      sql_object = gsub("^\\[?IDI_UserCode\\]?\\.?", "", sql_object)
    }
    
    # make query
    type = ifelse(is_view, "VIEW", "TABLE")
    drop_query = glue::glue("DROP {type} IF EXISTS {sql_object}")

    # execute query
    ADAPT::run_time_inform_user(glue::glue("Droping {sql_object}"))
    DBI::dbExecute(db_connection, drop_query)
  }
  
  ADAPT::run_time_inform_user(glue::glue("{COHORT} complete"))
}

DBI::dbDisconnect(db_connection)
ADAPT::run_time_inform_user(glue::glue("Removing SQL tables and views complete"))
