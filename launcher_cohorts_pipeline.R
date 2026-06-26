################################################################################
# Launcher for Cohorts Pipeline
# 
# Only a single version of the launcher is required
# Once you 'source' this file and R is running, then it is safe for another
# user / session to modify this file and 'source' it themselves.
################################################################################

## User parameters -------------------------------------------------------- ----

# name of cohort (comma-separated names are processed in batches)
COHORT = "_test"

# refresh
REFRESH = 202603

# delay (occurs after setup before execution)
delay_minutes = 0

# Base analysis folder (should be folder containing the launcher R scripts)
BASE_FOLDER = "~/Network-Shares/DataLabNas/MAA/MAA2026-04/Cohorts pipeline - matching/"

## Launch pipeline -------------------------------------------------------- ----

tool_script = file.path(BASE_FOLDER, "6 Automation", "Automation scripts", "run_cohorts_pipeline.R")
source(tool_script, local = TRUE)
