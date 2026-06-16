/**************************************************************************************************
Title: Compress master table for time series analysis

Parameters & Present values:
	Current refresh = 202506
	Project schema = [DL-MAA2023-46]
	Cohort term for injection = $COHORT

**************************************************************************************************/
--Compress master to save space--
ALTER TABLE [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
