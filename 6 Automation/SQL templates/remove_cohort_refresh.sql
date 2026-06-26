/******************************************************************************
Delete tables and views from cohort-refresh run

This script is used to remove cohort-and-refresh-specific tables. This helps
keey UserCode and the Sandpit tidy. It should be run manually as including
it in a pipeline risks accidentally dropping tables.

History:
2026-04-13 SA initial version based on DY design
2026-02-04 DY Created initial version
******************************************************************************/

USE IDI_UserCode
GO

-- input cohort tables
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_possible_client_matches_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_possible_target_matches_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}]

-- matching processing tables
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_comparison_matching_master_table_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matching_master_table_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_comparison_matched_uids_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matched_uids_{REFRESH}]
  
-- output master tables
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
  
-- views
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_tmp_helper_{REFRESH}]
  
