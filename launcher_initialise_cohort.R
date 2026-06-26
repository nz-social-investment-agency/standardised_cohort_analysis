################################################################################
# Launcher for initialising a new cohort or a new refresh for an existing cohort
# 
# Creates cohort and refresh folders if needed, copying over file templates.
################################################################################

## User parameters -------------------------------------------------------- ----

# name for the cohort
COHORT = "_test"

# refresh
REFRESH = 202603

# date that cross-section analysis uses to calculate current age
CURRENT_DATE = "2025-12-31"

# if control files and templates already exist should they be regenerated
REBUILD_TEMPLATES = TRUE

# if cohort setup already exists should it be overwritten with empty template
OVERWRITE_COHORT = FALSE

# specify alternative templates or control files (purpose = file name)
SPECIFY_TEMPLATE = list()

# Base analysis folder (should be folder containing the launcher R scripts)
BASE_FOLDER = "~/Network-Shares/DataLabNas/MAA/MAA2026-04/Cohorts pipeline - matching/"

## Launch pipeline -------------------------------------------------------- ----

tool_script = file.path(BASE_FOLDER, "6 Automation", "Automation scripts", "run_initialise_cohort.R")
source(tool_script, local = TRUE)
