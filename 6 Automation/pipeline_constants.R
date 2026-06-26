################################################################################
# Project constants
#
# This script sets constants that will be used throughout the pipeline.
# These affect all analysis tables but not definition tables.
################################################################################

## User parameters -------------------------------------------------------- ----

# Prefix used for tables in the IDI
PREFIX = "CHT_"

# default database and schema (do not include square brackets)
PROJECT_DB = 'SIA_Sandpit'
PROJECT_SCHEMA = 'DL-MAA2026-04'

## Database connection ---------------------------------------------------- ----

db_connection_string = paste(
  "DRIVER=ODBC Driver 18 for SQL Server;",
  "Trusted_Connection=Yes;",
  "TrustServerCertificate=Yes;",
  "DATABASE=IDI_UserCode;",
  "SERVER=PRTPRDSQL36, 1433"
)

## Base folder from SQL server -------------------------------------------- ----
# Paths from R and paths from SQL server look a little different

SQL_FOLDER = gsub("~/Network-Shares/DataLabNas/", "//prtprdsasnas01/DataLab/", BASE_FOLDER, fixed = TRUE)
SQL_FOLDER = file.path(SQL_FOLDER, "1 Definitions", "Reference files")
SQL_FOLDER = glue::glue(gsub("/", "\\", SQL_FOLDER, fixed = TRUE))

## Save settings to RDS --------------------------------------------------- ----

saveRDS(
  list(
    PREFIX = PREFIX,
    PROJECT_DB = PROJECT_DB,
    PROJECT_SCHEMA = PROJECT_SCHEMA,
    db_connection_string = db_connection_string,
    SQL_FOLDER = SQL_FOLDER
  ),
  file = file.path(BASE_FOLDER, "6 Automation", "pipeline_settings.RDS")
)
