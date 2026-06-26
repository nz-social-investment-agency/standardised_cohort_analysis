/**************************************************************************************************
Title: Learning Supports
Author: Charlotte Rose
Peer review: Simon Anastasiadis

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions]
- [IDI_Metadata_$(REFRESH)].[moe_school].[se_service_category_code]
- [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code]
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol]
- [IDI_Metadata].[clean_read_CLASSIFICATIONS].[moe_provider]
- [IDI_Metadata_$(REFRESH)].[moe_school].[provider_type_code]
- max_date MOE student_enrol.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_enrol]

Description: 
This defines learning supports received. Included are:
- Reading Recovery
- High Health Students identified in Enrol 
- Resource Teachers: Literacy
- Interim Response Fund 
- Special Education 
- Resource Teacher: Learning and Behaviour 
- Special Education

Additonally, enrolment in a specialist school is included as is ORS (ongoing resourcing scheme)

Intended purpose:
Indicator for cohort analysis which shows if someone has higher educational needs AND is getting support
Not suitable for duration calculations in its present form.

Notes:
- This is an indicator of support received only, not a comprehensive indicator of childrens educational needs.

- While not all learning supports will be of interest for every cohort, it has been decided to include all those listed above under the umbrella of learning support
	to provide a general idea of the extra support a child is receiving, regardless of the reason.


Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
 
History (reverse order):
2025-11-06 SA cap open spells with max_date
2025-06-12 CR
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_learning_supports_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_learning_supports_$(REFRESH)] AS
WITH max_date AS (
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_enrol_$(REFRESH)]
)
-- from student intervention
SELECT i.[snz_uid]
	  ,IIF([moe_inv_intrvtn_code] = 39,[moe_inv_se_service_category_code],[moe_inv_intrvtn_code]) as type_code
	  ,IIF([moe_inv_intrvtn_code] = 39,CONCAT(t.InterventionName,': ',se.SEServiceCategoryDescription),t.InterventionName) AS [type]
      ,[moe_inv_start_date] AS [start_date]
      ,[moe_inv_end_date] AS [raw_end_date]
	  ,CASE -- all reference dates become max-date
			WHEN [moe_inv_end_date] IS NULL THEN max_date
			WHEN YEAR([moe_inv_end_date]) = 1900 THEN max_date
			WHEN [moe_inv_end_date] > max_date THEN max_date
			ELSE [moe_inv_end_date]
			END AS [end_date]
	  ,e.moe_esi_provider_code
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] AS i
LEFT JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[se_service_category_code] AS se
ON se.[SEServiceCategoryId] = i.[moe_inv_se_service_category_code]
INNER JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code] AS t 
ON t.InterventionID = i.moe_inv_intrvtn_code
INNER JOIN [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol] AS e 
ON e.snz_uid = i.snz_uid
AND e.moe_esi_start_date < i.[moe_inv_end_date]
AND i.[moe_inv_start_date] < e.moe_esi_end_date
CROSS JOIN max_date
WHERE [moe_inv_intrvtn_code] IN (
	16,	-- Reading Recovery
	27, -- High Health Students identified in Enrol
	31, -- Resource Teachers: Literacy
	37, -- Interim Response Fund
	48,-- Resource Teacher: Learning and Behaviour
	39--Special education
)


UNION ALL

-- specialist school
SELECT DISTINCT e.[snz_uid]
	  ,p.moe_provider_type_code AS type_code
	  ,pc.ProviderTypeDescription AS [type]
      ,e.moe_esi_start_date AS [start_date]
      ,e.moe_esi_end_date AS [raw_end_date]
	  ,IIF(e.moe_esi_end_date < max_date, e.moe_esi_end_date, max_date) AS [end_date]
	  ,e.moe_esi_provider_code
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol] AS e 
INNER JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[moe_provider] AS p
ON p.moe_provider_code = e.moe_esi_provider_code
INNER JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[provider_type_code] AS pc
ON pc.ProviderTypeID = p.moe_provider_type_code
CROSS JOIN max_date
WHERE p.moe_provider_type_code = 10026 -- Specialist school

UNION ALL

-- ORS: ongoing resourcing scheme
SELECT e.snz_uid
	,'ORS' AS type_code
	,'ORS' AS [type]
    ,ors.AssessmentDate AS [start_date]
    ,ors.ExitDate AS [raw_end_date]
	,IIF(ors.ExitDate < max_date, ors.ExitDate, max_date) AS [end_date]
	,e.moe_esi_provider_code
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol] AS e
INNER JOIN [IDI_Adhoc].[clean_read_MOE].[Student_ORS_Criterion_202409] AS ors
ON ors.snz_moe_uid = e.snz_moe_uid
AND ors.AssessmentDate < e.moe_esi_start_date
AND e.moe_esi_end_date < ors.ExitDate
CROSS JOIN max_date
GO
