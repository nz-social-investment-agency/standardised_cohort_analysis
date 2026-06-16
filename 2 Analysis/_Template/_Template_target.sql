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
	- Table naming is [COHORT_target]
	- File name is COHORT_target.sql
- File and table must exist even if no target
- Target population does not need to exclude clients
	these are excluded when master tables are initialised
	
- <<additional notes here>>

Parameters & Present values:
	Refresh = 202506
	Project schema = [DL-MAA2023-46]
	Cohort name = _Template

Issues:
 
History (reverse order):
2025-08-26 SA template defined
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table with required columns

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[_Template_target]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2023-46].[_Template_target] (
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

--INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[_Template_target]
--SELECT 
--FROM 


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2023-46].[_Template_client] (snz_uid)
