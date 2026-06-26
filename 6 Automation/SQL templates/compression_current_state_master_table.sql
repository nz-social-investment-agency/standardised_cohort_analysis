/**************************************************************************************************
Title: Compress master table for current state analysis

Parameters & Present values:
	Project database = {PROJECT_DB}
	Project schema = {PROJECT_SCHEMA}
	Pipeline prefix = {PREFIX}
	Cohort term for injection = {COHORT}
	
**************************************************************************************************/
--Compress master to save space--

-- original / naive
-- ALTER TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)

-- procedure / faster
EXEC [IDI_UserCode].[{PROJECT_SCHEMA}].[compress_table_{PROJECT_DB}] @table = '[{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]'
