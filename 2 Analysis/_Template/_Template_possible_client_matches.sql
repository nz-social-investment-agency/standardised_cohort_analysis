/**************************************************************************************************
Title: <<Template for defining possible matching cohort>>
Author: 
Peer review:

Inputs & Dependencies:
- <<list input date sources>>

Description:
<<add description of how cohort is defined>>

Intended purpose:
This definition lists all the people who might be matched to the client group.
The cohorts pipeline uses this definition for the comparison matching analysis.

Notes:
- Required conventions for this file:
	- Table must have snz_uid, and reference_year columns
	- Table naming is [COHORT_possible_client_matches]
	- File name is COHORT_possible_client_matches.sql
- File and table must exist even if no clients
- Possible-matches population does not need to exclude to-match
	population, these are excluded when master tables are initialised

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

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[_Template_possible_client_matches]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2023-46].[_Template_possible_client_matches] (
	snz_uid INT NOT NULL
	,reference_year INT NOT NULL
)
GO

------------------------------------------------------------------------------------------------
-- Define population


------------------------------------------------------------------------------------------------
-- Insert into table

--INSERT INTO [SIA_Sandpit].[DL-MAA2023-46].[_Template_possible_client_matches]
--SELECT 
--FROM 


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2023-46].[_Template_possible_client_matches] (snz_uid)
