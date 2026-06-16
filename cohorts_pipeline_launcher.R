################################################################################
# Launcher for Cohorts Pipeline
################################################################################

## User parameters -------------------------------------------------------- ----

# Cohort (NA = user interface, comma-separated values allow batch processing)
COHORT = 'MTFJ,SouthSeas,StandTu,Emerge'

# Base analysis folder (should be folder containing this file)
BASE_FOLDER = "~/Network-Shares/DataLabNas/MAA/MAA2023-46/projects/Cohorts pipeline"

# delay (occurs after setup before execution)
delay_minutes = 0

# write console log to file (appends to existing file, NA deactivates)
log_file = "run_pipeline_log.txt"

## Launch pipeline -------------------------------------------------------- ----

tool_script = file.path(BASE_FOLDER, "6 Automation", "Automation scripts", "tool_pipeline.R")
source(tool_script, local = TRUE)
