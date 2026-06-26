/**************************************************************************************************
Title: Compress master table for forecast matching analysis

Parameters & Present values:
	Project database = {PROJECT_DB}
	Project schema = {PROJECT_SCHEMA}
	Pipeline prefix = {PREFIX}
	Cohort term for injection = {COHORT}
	Refresh = {REFRESH}

**************************************************************************************************/
--Compress master to save space--

-- original / naive
ALTER TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matching_master_table_{REFRESH}] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)

-- procedure / faster - does not work as table contains an IDENTITY column
-- EXEC [IDI_UserCode].[{PROJECT_SCHEMA}].[compress_table_{PROJECT_DB}] @table = '[{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matching_master_table_{REFRESH}]'
