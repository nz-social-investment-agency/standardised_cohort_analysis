/**************************************************************************************************
Title: Initialise master table for current state analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [IDI_Clean].[data].[personal_detail]
- [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
- [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603]

Intended purpose:
Initialise the master table that will be used for current state results.

Notes:
Current date needs to be manually updated with the approximate max date for the refresh, usually the end of the previous quarter (i.e. june refresh -> end of march)

Parameters & Present values:
	Project database = SIA_Sandpit
	Project schema = DL-MAA2026-04
	Pipeline prefix = CHT_
	Cohort term for injection = _test
	Current refresh = 202603
	Current date = 2025-12-31
	
Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603] (
	snz_uid INT NOT NULL
	,snz_mother_uid INT
	,snz_father_uid INT
	,period VARCHAR(20) NOT NULL
	,organisation VARCHAR(20) NOT NULL
	,client_status VARCHAR(20) NOT NULL
	,[current_date] DATE NOT NULL
	,reference_date DATE NOT NULL
	,std_start_date DATE
	,std_end_date DATE
	,lag1_start_date DATE
	,lag1_end_date DATE
	,lag2_start_date DATE
	,lag2_end_date DATE
	,entity_cohort_mha INT
	,entity_cohort_edu INT
	,entity_cohort_pbn INT
	,entity_cohort_ent INT
)
GO

------------------------------------------------------------------------------------------------
-- Insert client records

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '_test' AS organisation
	, 'client' AS client_status
	, '2025-12-31' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
WHERE current_client = 1
AND linked_uid = 1
GO

------------------------------------------------------------------------------------------------
-- Insert target records excl. clients

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '_test' AS organisation
	, 'target-not-client' AS client_status
	, '2025-12-31' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603]
WHERE snz_uid NOT IN (
	SELECT snz_uid
	FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
	WHERE current_client = 1
	AND linked_uid = 1
)
GO

------------------------------------------------------------------------------------------------
-- Insert GenPop records

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '_test' AS organisation
	, 'genpop' AS client_status
	, '2025-12-31' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603]
GO

------------------------------------------------------------------------------------------------
-- index

CREATE NONCLUSTERED INDEX i_uid_date ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603] (snz_uid) INCLUDE (reference_date)
GO

-------------------------------------------------------------------------------------------------
--Add lag dates

UPDATE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
SET std_start_date	 = DATEADD(DAY,1,DATEADD(YEAR,-1,reference_date))
	,std_end_date	 = reference_date
	,lag1_start_date = DATEADD(DAY,1,DATEADD(YEAR,-2,reference_date))
	,lag1_end_date	 = DATEADD(YEAR,-1,reference_date)
	,lag2_start_date = DATEADD(DAY,1,DATEADD(YEAR,-3,reference_date))
	,lag2_end_date	 = DATEADD(YEAR,-2,reference_date)
GO

------------------------------------------------------------------------------------------------
-- Add parents

UPDATE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
SET snz_mother_uid = IIF(pm.snz_sex_gender_code = 2, p.snz_parent1_uid,NULL)
	,snz_father_uid = IIF(pf.snz_sex_gender_code = 1 AND p.snz_parent2_uid = p.snz_parent1_uid,p.snz_parent2_uid,NULL)
FROM [IDI_Clean_202603].[data].[personal_detail] AS p
LEFT JOIN [IDI_Clean_202603].[data].[personal_detail] AS pm
ON p.snz_parent1_uid = pm.snz_uid 
LEFT JOIN [IDI_Clean_202603].[data].[personal_detail] AS pf
ON p.snz_parent2_uid = pf.snz_uid 
WHERE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603].snz_uid = p.snz_uid
GO
