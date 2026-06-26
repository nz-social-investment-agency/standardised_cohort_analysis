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
	Project schema = {PROJECT_SCHEMA}
	Cohort name = {COHORT}
	Refresh = {REFRESH}

Issues:
 
History (reverse order):
2026-05-26 SA GenPop template created
2026-04-13 SA template aligned with glue
2025-08-26 SA template defined
**************************************************************************************************/

------------------------------------------------------------------------------------------------
-- Create table with required columns

DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}]
GO

CREATE TABLE [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}] (
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

/******UPDATE DEMOGRAPHICS AND REFERENCE DATE********/
------------------------------------------------------------------------------------------------
-- Insert into table

--INSERT INTO [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}]
--SELECT 
--FROM 

--SELECT DISTINCT r.[snz_uid]
--   ,'2025-12-31' AS reference_date /*UPDATE*/
--FROM [IDI_Clean_202603].[data].[snz_res_pop] AS r
--INNER JOIN [IDI_Clean_202603].[data].[personal_detail] AS p
--ON r.snz_uid = p.snz_uid
--INNER JOIN [IDI_UserCode].[DL-MAA2026-04].[defn_address_higher_geog_202603] AS a
--ON r.snz_uid = a.snz_uid
--AND '2025-12-31' BETWEEN a.ant_notification_date AND a.ant_replacement_date /*UPDATE*/
--AND YEAR(srp_ref_date) = 2025 -- current resident
--AND p.snz_spine_ind = 1 -- must be on spine
--AND p.snz_person_ind = 1 -- must be a person
--AND p.snz_birth_date_proxy IS NOT NULL -- has birth date
--AND p.snz_deceased_year_nbr IS NULL -- has not died
--AND DATEDIFF(MONTH,p.snz_birth_date_proxy,'2025-12-31') / 12 = /*UPDATE*/


------------------------------------------------------------------------------------------------
-- Tidy up

-- <<remove any temporary objects>>

------------------------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid ON [{PROJECT_DB}].[{PROJECT_SCHEMA}].[{PREFIX}{COHORT}_genpop_{REFRESH}] (snz_uid)
