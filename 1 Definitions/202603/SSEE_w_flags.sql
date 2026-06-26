 /**************************************************************************************************
Title: Stand downs, Suspensions, Exclusions and Expulsions
Author: Charlotte Rose
Peer review: Simon Anastasiadis

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] 
- [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code]
- [IDI_Metadata_$(REFRESH)].[moe_school].[sds_type_code]
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol]
- max_date MOE student_interventions.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_interventions]

Description: 
Identifies stand down, suspension, exclusion and expulsion events. These events mean a child is not allowed at school usually due to rule breaking
or behaviour issues. The child can either return to school with agreements, or be removed from the roll.
- Stand downs are 'cooling off periods'. They tend to be short periods of time where a student not allowed at school. Whanau and teachers will work together to
	manage behaviour
- Suspensions are longer periods where a child is not allowed at school and requires the board to meet to dicuss next steps.
	The outcome of a suspension can include returning to school with or without conditions. More serious outcomes mean a child is removed from the school roll
		-Exclusions are when a child under the age of 16 is removed from the school roll
		-Expulsions are when a young person over the age of 16 is removed from hte school roll

Intended purpose:
Indicator for cohort analysis to identified those students with challenges which are effecting their educational engagement

Notes:
- Because exclusions and explusions are outcomes of suspensions rather than a seperate intervention type, a flag has been included as to  
	whether a suspension resulted in either an exlusion or an explusion.


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

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_SSEE_w_flag_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_SSEE_w_flag_$(REFRESH)] AS
WITH max_date AS (
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_interventions_$(REFRESH)]
)
SELECT DISTINCT i.snz_uid
	,i.moe_inv_start_date
	,i.moe_inv_end_date AS raw_moe_inv_end_date
	,CASE -- all reference dates become max-date
			WHEN [moe_inv_end_date] IS NULL THEN max_date
			WHEN YEAR([moe_inv_end_date]) = 1900 THEN max_date
			WHEN [moe_inv_end_date] > max_date THEN max_date
			ELSE [moe_inv_end_date]
			END AS [moe_inv_end_date]
	,i.moe_inv_intrvtn_code
	,t.InterventionName
	,IIF(i.moe_inv_intrvtn_code = 8, 1, NULL) AS standdown_flag
	,IIF(i.moe_inv_intrvtn_code = 7, 1, NULL) AS suspension_flag
	,IIF(i.moe_inv_intrvtn_code = 7 AND s.sDSTypeCode IN (13,5,6,7),1,NULL) AS exp_flag -- expulsion or exclusion
	,i.moe_inv_inst_num_code as moe_esi_provider_code
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] i
INNER JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code] t
ON t.InterventionID = i.moe_inv_intrvtn_code
LEFT JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[sds_type_code] s
ON s.SDSTypeCode = i.moe_inv_standwn_susp_type_code
CROSS JOIN max_date
WHERE i.moe_inv_intrvtn_code IN (7,8)
AND YEAR([moe_inv_start_date]) <> 1900
-- exclude records with inconsistent end dates (effects <200 records, <0.1% of records)
AND (
	YEAR([moe_inv_end_date]) < 9999
	OR (YEAR([moe_inv_start_date]) > 2020 AND YEAR([moe_inv_end_date]) = 9999)
	OR (YEAR([moe_inv_start_date]) > 2020 AND [moe_inv_end_date] IS NULL)
)
GO


