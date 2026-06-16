/**************************************************************************************************
Title: Initialise master table for time series analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [IDI_Clean_202506].[data].[personal_detail]
- [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_client]
- [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_target]
- [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_comparison_matched_uids]
- [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_forecast_matched_uids]

Intended purpose:
Initialise the master table that will be used for time series results.

Notes:

Parameters & Present values:
	Current refresh = 202506
	Project schema = [DL-MAA2023-46]
	Cohort term for injection = $COHORT

Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table] (
	snz_uid INT NOT NULL
	,organisation VARCHAR(20) NOT NULL
	,client_status VARCHAR(20) NOT NULL
	,period INT NOT NULL
	,period_start DATE NOT NULL
	,period_end DATE NOT NULL
	,entity_cohort_mha INT
	,entity_cohort_edu INT
	,entity_cohort_pbn INT
	,entity_cohort_ent INT
)
GO

-----------------------------------------------------------------------------------------------
-- List of all identities

DROP TABLE IF EXISTS #setup
GO

CREATE TABLE #setup (
	snz_uid INT NOT NULL
	,client_status VARCHAR(20) NOT NULL
	,reference_date DATE NOT NULL
	,entity_cohort_mha INT
	,entity_cohort_edu INT
	,entity_cohort_pbn INT
	,entity_cohort_ent INT
)
GO

-- Client cohort
INSERT INTO #setup
SELECT snz_uid
	, 'client' AS client_status
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_client]
WHERE linked_uid = 1
GO

-- Target cohort excl. current cohort
INSERT INTO #setup
SELECT snz_uid
	, 'target-not-client' AS client_status
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_target]
WHERE snz_uid NOT IN (
	SELECT snz_uid
	FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_client]
	WHERE linked_uid = 1
)
GO

-- Comparison cohort
INSERT INTO #setup
SELECT snz_uid
	, 'comparison' AS client_status
	, reference_date
	, NULL AS entity_cohort_mha
	, NULL AS entity_cohort_edu
	, NULL AS entity_cohort_pbn
	, NULL AS entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_comparison_matched_uids]
GO

-- Forecast cohort
INSERT INTO #setup
SELECT snz_uid
	, 'forecast' AS client_status
	, reference_date
	, NULL AS entity_cohort_mha
	, NULL AS entity_cohort_edu
	, NULL AS entity_cohort_pbn
	, NULL AS entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_forecast_matched_uids]
GO

-----------------------------------------------------------
-- 2 years before

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,-2 AS period
	,DATEADD(YEAR, -2, reference_date) AS period_start
	,DATEADD(DAY, -1, DATEADD(YEAR, -1, reference_date)) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- 1 year before

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,-1 AS period
	,DATEADD(YEAR, -1, reference_date) AS period_start
	,DATEADD(DAY, -1, DATEADD(YEAR, 0, reference_date)) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- 1 year after

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,1 AS period
	,DATEADD(DAY, 1, DATEADD(YEAR, 0, reference_date)) AS period_start
	,DATEADD(YEAR, 1, reference_date) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- 2 years after

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,2 AS period
	,DATEADD(DAY, 1, DATEADD(YEAR, 1, reference_date)) AS period_start
	,DATEADD(YEAR, 2, reference_date) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- 3 years after

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,3 AS period
	,DATEADD(DAY, 1, DATEADD(YEAR, 2, reference_date)) AS period_start
	,DATEADD(YEAR, 3, reference_date) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- 4 years after

INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
SELECT snz_uid
	,'$COHORT' AS organisation
	,client_status AS client_status
	,4 AS period
	,DATEADD(DAY, 1, DATEADD(YEAR, 3, reference_date)) AS period_start
	,DATEADD(YEAR, 4, reference_date) AS period_end
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM #setup
GO

-----------------------------------------------------------
-- Remove future dates

DELETE FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
WHERE period_start >= GETDATE()
GO

-----------------------------------------------------------
-- index

CREATE NONCLUSTERED INDEX i_uid_date ON [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table] (snz_uid) INCLUDE (period_start, period_end)
GO
