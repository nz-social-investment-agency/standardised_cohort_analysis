/**************************************************************************************************
Title: Initialise master table for time series analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_comparison_matched_uids_{REFRESH}]
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matched_uids_{REFRESH}]

Intended purpose:
Initialise the master table that will be used for time series results.

Notes:

Parameters & Present values:
	Project database = {PROJECT_DB}
	Project schema = {PROJECT_SCHEMA}
	Pipeline prefix = {PREFIX}
	Cohort term for injection = {COHORT}
	Current refresh = {REFRESH}

Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table

DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
GO

CREATE TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}] (
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
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
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
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
WHERE snz_uid NOT IN (
	SELECT snz_uid
	FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
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
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_comparison_matched_uids_{REFRESH}]
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
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_forecast_matched_uids_{REFRESH}]
GO

-----------------------------------------------------------
-- 2 years before

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
SELECT snz_uid
	,'{COHORT}' AS organisation
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

DELETE FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}]
WHERE period_start >= GETDATE()
GO

-----------------------------------------------------------
-- index

CREATE NONCLUSTERED INDEX i_uid_date ON [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_time_series_master_table_{REFRESH}] (snz_uid) INCLUDE (period_start, period_end)
GO
