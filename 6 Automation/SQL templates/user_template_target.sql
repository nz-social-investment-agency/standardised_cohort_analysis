/**************************************************************************************************
Title: <<Template for defining target cohort>>
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
	- Table must have snz_uid, reference_date, four entity columns.
	- Table naming is [PREFIX_COHORT_target_REFRESH] this should auto generate
	- File name is target - COHORT_REFRESH.sql this should auto generate
	- File and table must exist even if no target
- Target population does not need to exclude clients
	these are excluded when master tables are initialised
	
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

DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
GO

CREATE TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}] (
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


------------------------------------------------------------------------------------------------
-- Insert into table

--INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}]
--SELECT 
--FROM 


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_target_{REFRESH}] (snz_uid)
