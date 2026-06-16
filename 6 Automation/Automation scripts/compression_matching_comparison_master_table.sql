/**************************************************************************************************
Title: Compress master table for comparison matching analysis

Parameters & Present values:
	Current refresh = 202506
	Project schema = [DL-MAA2023-46]
	Cohort term for injection = $COHORT

**************************************************************************************************/
--Compress master to save space--
ALTER TABLE [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_comparison_matching_master_table] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
