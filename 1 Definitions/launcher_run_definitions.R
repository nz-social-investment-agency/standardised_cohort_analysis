################################################################################
# Launcher for creating all definitions for a new refresh
# 
# Should be run once a new refresh is setup and ready to use
# but before any cohort analysis is run on that refresh.
################################################################################

## User parameters -------------------------------------------------------- ----

# delay (occurs after setup & before execution)
delay_minutes = 0

# refresh
REFRESH = 202603

# if control files and templates already exist should they be regenerated
REBUILD_TEMPLATES = FALSE

# Base analysis folder (should be folder containing the launcher R scripts)
BASE_FOLDER = "~/Network-Shares/DataLabNas/MAA/MAA2026-04/Cohorts pipeline - matching/"

# write console log to file (appends to existing file, NA deactivates)
log_file = "definition_log - {REFRESH}.txt"

## Launch pipeline -------------------------------------------------------- ----

tool_script = file.path(BASE_FOLDER, "6 Automation", "Automation scripts", "run_definitions.R")
source(tool_script, local = TRUE)
