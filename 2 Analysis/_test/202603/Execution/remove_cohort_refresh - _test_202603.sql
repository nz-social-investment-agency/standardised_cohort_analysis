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
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_client_matches_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603]

-- matching processing tables
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_comparison_matching_master_table_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_comparison_matched_uids_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matched_uids_202603]
  
-- output master tables
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_time_series_master_table_202603]
  
-- views
DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_time_series_master_table_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_tmp_helper_202603]
