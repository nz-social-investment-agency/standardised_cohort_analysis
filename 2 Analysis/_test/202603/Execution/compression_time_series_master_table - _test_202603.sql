/**************************************************************************************************
Title: Compress master table for time series analysis

Parameters & Present values:
	Project database = SIA_Sandpit
	Project schema = DL-MAA2026-04
	Pipeline prefix = CHT_
	Cohort term for injection = _test

**************************************************************************************************/
--Compress master to save space--

-- original / naive
-- ALTER TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_time_series_master_table_202603] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)

-- procedure / faster
EXEC [IDI_UserCode].[DL-MAA2026-04].[compress_table_SIA_Sandpit] @table = '[SIA_Sandpit].[DL-MAA2026-04].[CHT__test_time_series_master_table_202603]'
