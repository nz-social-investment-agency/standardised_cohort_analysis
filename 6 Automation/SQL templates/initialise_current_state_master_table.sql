/**************************************************************************************************
Title: Initialise master table for current state analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [IDI_Clean].[data].[personal_detail]
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
- [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]

Intended purpose:
Initialise the master table that will be used for current state results.

Notes:
Current date needs to be manually updated with the approximate max date for the refresh, usually the end of the previous quarter (i.e. june refresh -> end of march)

Parameters & Present values:
	Project database = {PROJECT_DB}
	Project schema = {PROJECT_SCHEMA}
	Pipeline prefix = {PREFIX}
	Cohort term for injection = {COHORT}
	Current refresh = {REFRESH}
	Current date = {CURRENT_DATE}
	
Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table

DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
GO

CREATE TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}] (
	snz_uid INT NOT NULL
	,snz_mother_uid INT
	,snz_father_uid INT
	,snz_caregiver1_uid INT
	,snz_caregiver2_uid INT
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

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '{COHORT}' AS organisation
	, 'client' AS client_status
	, '{CURRENT_DATE}' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
WHERE current_client = 1
AND linked_uid = 1
GO

------------------------------------------------------------------------------------------------
-- Insert target records excl. clients

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '{COHORT}' AS organisation
	, 'target-not-client' AS client_status
	, '{CURRENT_DATE}' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
WHERE snz_uid NOT IN (
	SELECT snz_uid
	FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
	WHERE current_client = 1
	AND linked_uid = 1
)
GO

------------------------------------------------------------------------------------------------
-- Insert GenPop records

INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
(snz_uid, period, organisation, client_status, [current_date], reference_date, entity_cohort_mha, entity_cohort_edu, entity_cohort_pbn, entity_cohort_ent)
SELECT snz_uid
	, 'Current' AS period
	, '{COHORT}' AS organisation
	, 'genpop' AS client_status
	, '{CURRENT_DATE}' AS [current_date]
	, reference_date
	, entity_cohort_mha
	, entity_cohort_edu
	, entity_cohort_pbn
	, entity_cohort_ent
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}]
GO

------------------------------------------------------------------------------------------------
-- index

CREATE NONCLUSTERED INDEX i_uid_date ON [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}] (snz_uid) INCLUDE (reference_date)
GO

-------------------------------------------------------------------------------------------------
--Add lag dates

UPDATE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
SET std_start_date	 = DATEADD(DAY,1,DATEADD(YEAR,-1,reference_date))
	,std_end_date	 = reference_date
	,lag1_start_date = DATEADD(DAY,1,DATEADD(YEAR,-2,reference_date))
	,lag1_end_date	 = DATEADD(YEAR,-1,reference_date)
	,lag2_start_date = DATEADD(DAY,1,DATEADD(YEAR,-3,reference_date))
	,lag2_end_date	 = DATEADD(YEAR,-2,reference_date)
GO

------------------------------------------------------------------------------------------------
-- Add parents and caregivers

-- mother
UPDATE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
SET snz_mother_uid = pcg.snz_associated_uid
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_child_parent_{REFRESH}] AS pcg
WHERE pcg.relationship = 'birth_mother'
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].reference_date <= pcg.[end_date]
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].snz_uid = pcg.snz_uid
GO

-- father
UPDATE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
SET snz_father_uid = pcg.snz_associated_uid
FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_child_parent_{REFRESH}] AS pcg
WHERE pcg.relationship = 'birth_father'
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].reference_date <= pcg.[end_date]
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].snz_uid = pcg.snz_uid
GO

-- non-parent caregiver 1
WITH caregivers AS (

	SELECT pcg.snz_uid
		, pcg.snz_associated_uid
		, MAX(pcg.[start_date]) AS [start_date]
	FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_child_parent_{REFRESH}] AS pcg
	WHERE EXISTS (
		SELECT 1
		FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}] AS mt
		WHERE pcg.snz_uid = mt.snz_uid
		AND mt.reference_date <= pcg.[end_date]
	)
	AND pcg.relationship NOT LIKE 'birth%'
	GROUP BY pcg.snz_uid
		, pcg.snz_associated_uid

)
,ranked AS (

	SELECT pcg.*
		,ROW_NUMBER() OVER (PARTITION BY pcg.snz_uid ORDER BY [start_date] DESC, snz_associated_uid) AS rn
	FROM caregivers AS pcg

)
UPDATE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
SET snz_caregiver1_uid = ranked.snz_associated_uid
FROM ranked
WHERE ranked.rn = 1
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].snz_uid = ranked.snz_uid
GO

-- non-parent caregiver 2
WITH caregivers AS (

	SELECT pcg.snz_uid
		, pcg.snz_associated_uid
		, MAX(pcg.[start_date]) AS [start_date]
	FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_child_parent_{REFRESH}] AS pcg
	WHERE EXISTS (
		SELECT 1
		FROM [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}] AS mt
		WHERE pcg.snz_uid = mt.snz_uid
		AND mt.reference_date <= pcg.[end_date]
	)
	AND pcg.relationship NOT LIKE 'birth%'
	GROUP BY pcg.snz_uid
		, pcg.snz_associated_uid

)
,ranked AS (

	SELECT pcg.*
		,ROW_NUMBER() OVER (PARTITION BY pcg.snz_uid ORDER BY [start_date] DESC, snz_associated_uid) AS rn
	FROM caregivers AS pcg

)
UPDATE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}]
SET snz_caregiver2_uid = ranked.snz_associated_uid
FROM ranked
WHERE ranked.rn = 2
AND [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_current_state_master_table_{REFRESH}].snz_uid = ranked.snz_uid
GO
