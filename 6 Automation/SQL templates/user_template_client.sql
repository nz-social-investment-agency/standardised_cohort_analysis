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
	Project schema = {PROJECT_SCHEMA}
	Cohort name = {COHORT}
	Refresh = {REFRESH}

Issues:
 
History (reverse order):
2026-04-13 SA template aligned with glue
2025-08-26 SA template defined
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table with required columns

DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
GO

CREATE TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}] (
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


------------------------------------------------------------------------------------------------
-- Insert into table

--INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}]
--SELECT 
--FROM 


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_client_{REFRESH}] (snz_uid)
