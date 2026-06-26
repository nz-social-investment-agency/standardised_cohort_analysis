/**************************************************************************************************
Title: Alternative Education
Author: Lexi XU

Inputs & Dependencies:
	[IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions]
	[IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol]
	[IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code]
	max_date MOE student_interventions.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_interventions]
	
Description: 
-- This view identifies students who received an Alternative Education intervention ([moe_inv_intrvtn_code] = 6)
-- Including each student's intervention periods and the school they were enrolled in at that time.
-- A student is included only if their school enrolment overlapped with the intervention period.

Intended purpose:
Indicator for cohort analysis which show students who placed in alternative education and link to their school 
enrolment at the time
The second half needs to be used for duration calculations.

Note:
1) Students with no matching enrolment data are excluded, as we cannot determine their school context.
2) End dates for interventions are NULL, 9999, and 1900 in the raw data.
	Best guess is that these records reflect inconistent handling of ongoing interventions.
	If the start date is recent (>2020), then such end dates are set to today's date.
	If the start date is older, then assumed end date was never provided and discard record as incomplete.
3) Concurrent enrollments are common throughout the Alternative Education defintion.
	In some cases this is because a school hosts the Alt Ed facility, and the student is
	enrolled at both the school and the Alt Ed facility within it.
	In order to calculate duration, we provide merge spells to a Sandpit table.
	Entity counts should still be calcualted from the View.
	
Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = [$(PROJECT_SCHEMA)]

History (reverse order):
2025-11-06 SA cap open spells with max_date
2025-10-24 SA merged spells added as extension for counting days
2025-06-19 LX v1
2025-06-23 LX & SA update with improved end dates
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)] AS
WITH max_date AS (
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_interventions_$(REFRESH)]
),
student_intervention_setup AS (
	SELECT snz_uid
		,[moe_inv_intrvtn_code]
		,[moe_inv_start_date]
		,CASE -- all reference dates become max-date
			WHEN [moe_inv_end_date] IS NULL THEN max_date
			WHEN YEAR([moe_inv_end_date]) = 1900 THEN max_date
			WHEN [moe_inv_end_date] > max_date THEN max_date
			ELSE [moe_inv_end_date]
			END AS [moe_inv_end_date]
	FROM 
		[IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions]
	CROSS JOIN
		max_date
	WHERE
		YEAR([moe_inv_start_date]) <> 1900
		-- exclude records with inconsistent end dates (effects <200 records, <0.1% of records)
		AND (
			YEAR([moe_inv_end_date]) < 9999
			OR (YEAR([moe_inv_start_date]) > 2020 AND YEAR([moe_inv_end_date]) = 9999)
			OR (YEAR([moe_inv_start_date]) > 2020 AND [moe_inv_end_date] IS NULL)
			)
)
SELECT 
    si.[snz_uid]
   ,[moe_inv_intrvtn_code] AS intervention_type_id
   ,t.InterventionName AS intervention_type_name
   ,[moe_inv_start_date]  AS start_date
   ,CAST([moe_inv_end_date]AS DATE) AS end_date
   ,[moe_esi_provider_code]
FROM 
	student_intervention_setup AS si	
INNER JOIN 
	[IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code] AS t 
	ON t.InterventionID = si.moe_inv_intrvtn_code
INNER JOIN
	[IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol] AS e
	ON si.snz_uid = e.snz_uid
	AND moe_esi_start_date <= moe_inv_end_date
	AND moe_inv_start_date <= moe_esi_end_date
WHERE 
	si.[moe_inv_intrvtn_code] = 6  -- alternative education
GO

-------------------------------------------------------------------------------
-- Merge

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_alternative_education_merged_$(REFRESH)]
GO

WITH
/* exclude start dates that are within another spell */
possible_starts AS (
	SELECT snz_uid
		,[start_date]
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)]  AS s1
	WHERE NOT EXISTS (
		SELECT 1
		FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)]  AS s2
		WHERE s1.snz_uid = s2.snz_uid
		AND DATEADD(DAY, -1, s1.[start_date]) BETWEEN s2.[start_date] AND s2.[end_date]
	)
),
/* exclude end dates that are within another spell */
possible_ends AS (
	SELECT snz_uid
		,[end_date]
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)]  AS e1
	WHERE NOT EXISTS (
		SELECT 1
		FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_alternative_education_$(REFRESH)]  AS e2
		WHERE e1.snz_uid = e2.snz_uid
		AND e1.[end_date] BETWEEN DATEADD(DAY, -1, e2.[start_date]) AND DATEADD(DAY, -1, e2.[end_date])
	)
)
SELECT s.snz_uid
	,s.[start_date] AS alt_ed_start_date
	,MIN(e.[end_date]) AS alt_ed_end_date
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_alternative_education_merged_$(REFRESH)]
FROM possible_starts AS s
INNER JOIN possible_ends AS e
ON s.snz_uid = e.snz_uid
AND s.[start_date] <= e.[end_date]
GROUP BY s.snz_uid
	,s.[start_date]
GO

-- Compression
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_alternative_education_merged_$(REFRESH)]'
GO

CREATE NONCLUSTERED INDEX i_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_alternative_education_merged_$(REFRESH)] (snz_uid)
GO


