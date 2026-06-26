/**************************************************************************************************
Title: Spell managed by Corrections
Author: Simon Anastasiadis
Reviewer: Marianna Pekar, Joel Bancolita

Disclaimer:
The definitions provided in this library were determined by the Social Investment Agency to be suitable in the 
context of a specific project. Whether or not these definitions are suitable for other projects depends on the 
context of those projects. Researchers using definitions from this library will need to determine for themselves 
to what extent the definitions provided here are suitable for reuse in their projects. While the Agency provides 
this library as a resource to support IDI research, it provides no guarantee that these definitions are fit for reuse.

Citation:
Social Wellbeing Agency. Definitions library. Source code. https://github.com/nz-social-investment-agency/definitions_library

Description:
A spell for a person in New Zealand with any management by Corrections.

Intended purpose:
1. Creating indicators of when/whether a person has been managed by corrections.
2. Identifying spells when a person is under Corrections management.
3. Counting the number of days a person spends under Corrections management.

Inputs & Dependencies:
- [IDI_Community].[crim_major_management_spells].[major_management_spells]
Outputs:
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_corrections_any]
 
Notes:
1) Corrections management includes prison sentences (PRISON), remanded in custody (REMAND),
   supervision (ESO, INT_SUPER, SUPER), home detention (HD_REL, HD_SENT), conditions
   (PAROLE, ROC, PDC, PERIODIC), and community sentences (COM_DET, CW, COM_PROG, COM_SERV, OTH_COM)
2) This data set includes only major management periods, of which Prison is one type.
   Where a person has multiple management/sentence types this dataset only records the
   most severe. See introduction of Corrections documentation (2016).
3) Dataset history:
	> From 202203 refresh the [ov_major_mgmt_periods] was renamed to [ov_major_mgmt_periods_historic]
		and we began using its replacement: [ra_ofndr_major_mgmt_period_a].
	> From 202506 refresh, the Corrections updated the way they provided data into the IDI.
		The new provision is more sustainable. However, it is not as easy for researchers to use.
		We rebuilt our own version of the major management periods table. The source code
		for this is in: 'Corrections major management periods.sql'
	> From 202603 refresh, the Corrections code module became available. We migrate to this
		using a view to adjust for the key areas of difference.
4) Our view makes three key changes to the Code Module:
	1. spells are capped by max-date to avoid analyses beyond end-date of source dataset
	2. where one spell ends and another starts on a single day, the ending spell has been shortened
		by one day to avoid overlaps
	3. Imprisonment and Remand type labels have been simplified.


Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
 
History (reverse order):
2026-04-07 SA convert to use code module
2026-04-01 CF updated refresh to 202603
2025-11-06 SA remove -1 DAY from end date as source defn no longer contains overlaps
2024-08-07 SA update for change to ra_ofndr_major_mgmt_period_a
2021-06-04 FL update the input table to the latest reference
2020-07-22 JB QA
2020-07-16 MP QA
2020-02-28 SA v1
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

/* Set database for writing views */
USE IDI_UserCode
GO

/* Clear existing view */
DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_corrections_any_$(REFRESH)]
GO

/* Create view */
CREATE VIEW [$(PROJECT_SCHEMA)].[defn_corrections_any_$(REFRESH)] AS
WITH max_date AS (
	
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_COR_management_$(REFRESH)]

),
fetch_next_start AS (

	SELECT *
		,LEAD([comb_period_start_date], 1, '9999-12-31') OVER (PARTITION BY offender_id ORDER BY [comb_period_start_date]) AS next_start
	FROM [IDI_Community].[crim_major_management_spells].[major_management_spells_$(REFRESH)]

),
no_overlap_spells AS (

	SELECT [offender_id]
		,[comb_period_start_date]
		,IIF(next_start = [comb_period_end_date], DATEADD(DAY, -1, [comb_period_end_date]), [comb_period_end_date]) AS [comb_period_end_date]
		,[directive_type]
	FROM fetch_next_start 

)
SELECT CAST([offender_id] AS INT) AS snz_uid

    ,[comb_period_start_date] AS [start_date]
    ,[comb_period_end_date] AS [raw_end_date]
	,IIF([comb_period_end_date] < max_date, [comb_period_end_date], max_date) AS [end_date]

    ,CASE
		WHEN [directive_type] IN (
			'LIFE IMPRISONMENT'
			,'OTHER IMPRISONMENT'
			,'PREVENTIVE DETENTION [IMPRISONMENT]'
		) THEN 'IMPRISONMENT'
		WHEN [directive_type] = 'REMAND (ACCUSED / CONVICTED)' THEN 'REMAND'
		ELSE [directive_type]
		END AS [mm_type]

FROM no_overlap_spells
CROSS JOIN max_date
WHERE [comb_period_start_date] <= max_date
AND [directive_type] NOT IN ('')
AND [comb_period_start_date] IS NOT NULL
AND [comb_period_end_date] IS NOT NULL
GO
