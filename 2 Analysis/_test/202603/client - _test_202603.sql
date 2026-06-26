/**************************************************************************************************
Title: <<Template for defining client cohort>>
Author: 
Peer review:

Inputs & Dependencies:
- <<list input date sources>>

Description:
<<add description of how cohort is defined>>

Intended purpose:
The cohorts pipeline uses the contents of this definition for the matching analysis,
and to generate current state and time series outputs.

Notes:
- Required conventions for this file:
	- Table must have snz_uid, reference_date, four entity columns
	- Table must have linkd_uid column: 0 = not linked, 1 = linked to spine
	- Table must have current_client column: 0 = past client, 1 = current
	- Table must have no_dob column: 0 = has dob, 1 = missing date-of-birth
	- Table must have no_start_Date column: 0 = has start date, 1 = missing start date
	- Table naming is [PREFIX_COHORT_client_REFRESH] this should auto generate
	- File name is client - COHORT_REFRESH.sql this should auto generate
- File and table must exist even if no clients
- Use -1 for snz_uid if no record is not linked
- <<additional notes here>>

Parameters & Present values:
	Project schema = DL-MAA2026-04
	Cohort name = _test
	Refresh = 202603

Issues:
 
History (reverse order):
2026-04-13 SA template aligned with glue
2025-08-26 SA template defined
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table with required columns

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603] (
	snz_uid INT NOT NULL 
	,reference_date DATE NULL -- may be NULL but not when linked_uid = 1
	,linked_uid TINYINT NOT NULL
	,current_client TINYINT NOT NULL
	,no_dob TINYINT NOT NULL
	,no_start_date TINYINT NOT NULL
	,entity_cohort_mha INT NULL
	,entity_cohort_edu INT NULL
	,entity_cohort_pbn INT NULL
	,entity_cohort_ent INT NULL
)
GO

------------------------------------------------------------------------------------------------
-- Define population

-- A random sample of people aged 21 in 2024

SELECT TOP 100 *
INTO #setup
FROM [IDI_Clean_202603].[data].[personal_detail]
WHERE DATEDIFF(MONTH, snz_birth_date_proxy, '2024-12-31') / 12 = 21
AND snz_person_ind = 1
AND snz_spine_ind = 1

UNION ALL

SELECT TOP 10 *
FROM [IDI_Clean_202603].[data].[personal_detail]
WHERE DATEDIFF(MONTH, snz_birth_date_proxy, '2024-12-31') / 12 = 21
AND snz_person_ind = 1
AND snz_spine_ind = 0

------------------------------------------------------------------------------------------------
-- Insert into table

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603]
SELECT snz_uid
	,'2024-12-31' AS reference_date
	,IIF(snz_spine_ind = 0, 0, 1) AS linked_uid
	,1 AS current_client
	,0 AS no_dob
	,0 AS no_start_date
	,NULL AS ent_mha
	,NULL AS end_edu
	,NULL AS ent_pbn
	,NULL AS ent_ent
FROM #setup

------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_client_202603] (snz_uid)
