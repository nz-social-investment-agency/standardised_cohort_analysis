/**************************************************************************************************
Title: <<Template for defining possible matching cohort>>
Author: 
Peer review:

Inputs & Dependencies:
- <<list input date sources>>

Description:
<<add description of how cohort is defined>>

Intended purpose:
This definition lists all the people who might be matched to the target group.
The cohorts pipeline uses this definition for the forecast matching analysis.

Notes:
- Required conventions for this file:
	- Table must have snz_uid, and reference_year columns
	- Table naming is [PREFIX_COHORT_possible_target_matches_REFRESH] this should auto generate
	- File name is possible_target_matches - COHORT_REFRESH.sql this should auto generate
- File and table must exist even if no target
- Possible-matches population does not need to exclude to-match
	population, these are excluded when master tables are initialised

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

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603] (
	snz_uid INT NOT NULL
	,reference_year INT NOT NULL
)
GO

------------------------------------------------------------------------------------------------
-- Define population

-- Some residents aged 21 in 2019

SELECT TOP 5000 p.snz_uid
INTO #setup
FROM [IDI_Clean_202603].[data].[personal_detail] AS p
INNER JOIN [IDI_Clean_202603].[data].[snz_res_pop] AS r
ON YEAR(r.srp_ref_date) = 2019
AND p.snz_uid = r.snz_uid
WHERE DATEDIFF(MONTH, p.snz_birth_date_proxy, '2019-12-31') / 12 = 21
AND p.snz_person_ind = 1
AND p.snz_spine_ind = 1

------------------------------------------------------------------------------------------------
-- Insert into table

INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603]
SELECT snz_uid, 2019 AS reference_year
FROM #setup


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603] (snz_uid)
