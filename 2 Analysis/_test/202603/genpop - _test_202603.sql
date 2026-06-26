/**************************************************************************************************
Title: <<Template for defining general population cohort>>
Author: 
Peer review:

Inputs & Dependencies:
- <<list input date sources>>

Description:
<<add description of how cohort is defined>>

Intended purpose:
The cohorts pipeline uses the contents of this definition to generate current state.

Notes:
- Required conventions for this file:
	- Table must have snz_uid, reference_date, four entity columns.
	- Table naming is [PREFIX_COHORT_genpop_REFRESH] this should auto generate
	- File name is genpop - COHORT_REFRESH.sql this should auto generate
- File and table must exist even if no GenPop required
	
- <<additional notes here>>

Parameters & Present values:
	Project schema = DL-MAA2026-04
	Cohort name = _test
	Refresh = 202603

Issues:
 
History (reverse order):
2026-05-26 SA GenPop template created
2026-04-13 SA template aligned with glue
2025-08-26 SA template defined
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table with required columns

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603] (
	snz_uid INT NOT NULL
	,reference_date DATE NOT NULL
	,entity_cohort_mha INT NULL
	,entity_cohort_edu INT NULL
	,entity_cohort_pbn INT NULL
	,entity_cohort_ent INT NULL
)
GO

------------------------------------------------------------------------------------------------
-- Define population

-- An even bigger random sample of people aged 21 in 2024

SELECT TOP 3000 *
INTO #setup
FROM [IDI_Clean_202603].[data].[personal_detail]
WHERE DATEDIFF(MONTH, snz_birth_date_proxy, '2024-12-31') / 12 = 21
AND snz_person_ind = 1
AND snz_spine_ind = 1

------------------------------------------------------------------------------------------------
-- Insert into table

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603]
SELECT snz_uid
	,'2024-12-31' AS reference_date
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

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_genpop_202603] (snz_uid)
