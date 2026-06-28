/**************************************************************************************************
Title: Compress master table for forecast matching analysis

Parameters & Present values:
	Project database = SIA_Sandpit
	Project schema = DL-MAA2026-04
	Pipeline prefix = CHT_
	Cohort term for injection = _test
	Refresh = 202603

**************************************************************************************************/
--Compress master to save space--

-- original / naive
ALTER TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)

-- procedure / faster - does not work as table contains an IDENTITY column
-- EXEC [IDI_UserCode].[DL-MAA2026-04].[compress_table_SIA_Sandpit] @table = '[SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]'
