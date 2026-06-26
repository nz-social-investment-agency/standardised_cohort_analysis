/**************************************************************************************************
Title: Parental benefit duration indicator
Author: Charlotte Rose
Peer review: Simon Anastasiadis

Inputs & Dependencies:
- [IDI_Community].[inc_ise_main_benefit].[ise_main_benefit_$(REFRESH)]
- [IDI_Clean].[data].[person_relationship]
- [IDI_Clean].[data].[personal_detail]
- [IDI_Clean].[data].[snz_res_pop]
 
Outputs:
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_parent_benefit_duration_$(REFRESH)]

Description:
Creates a table with child-parent pairs and the % of the childs life that parent was on a main benefit

Intended purpose:
For use in ACE score calculation. This is a dependency for generalised ACE scores.

Notes:
1) This is a lifetime measure, not a spell measure
	So joining by a date range 
2) Significant revision to code April 2026. Swap to using spells when a child is recorded
	as being supported by a benefit. Merging across all adults as a single child may have multiple
	caregivers.

Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = $(PROJECT_SCHEMA)
 
Issues: 

History (reverse order):
2026-04-23 SA new version based on MSD_child table
2026-04-23 SA bug fixes - denominator too large
2026-04-20 SA Performance improvements 3 hrs >> 5 minutes
2025-09-11 SA review and QA
2024-10-22 - CR 
**************************************************************************************************/

--:SETVAR PROJECT_DB "SIA_Sandpit"
--:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
--:SETVAR REFRESH "202603"

-------------------------------------------------------------------------------
-- child and parent benefit spells

DROP TABLE IF EXISTS #parent_and_child_benefit
GO

SELECT c.[snz_uid] AS parent_snz_uid
    ,[child_snz_uid]
    ,[msd_chld_child_from_date]
    ,[msd_chld_child_to_date]
    ,[payment_start]
    ,[payment_end]
	,IIF([msd_chld_child_from_date] < [payment_start], [payment_start], [msd_chld_child_from_date]) AS trim_start
	,IIF([msd_chld_child_to_date] < [payment_end], [msd_chld_child_to_date], [payment_end]) AS trim_end
INTO #parent_and_child_benefit
FROM [IDI_Clean_$(REFRESH)].[msd_clean].[msd_child] AS c
INNER JOIN [IDI_Community].[inc_ise_main_benefit].[ise_main_benefit_$(REFRESH)] AS p
ON c.snz_uid = p.snz_uid
AND c.msd_chld_child_from_date <= p.payment_start
AND p.payment_end <= c.msd_chld_child_to_date
GO

CREATE NONCLUSTERED INDEX i_child ON #parent_and_child_benefit (child_snz_uid)
GO

-------------------------------------------------------------------------------
-- Condense spells
-- (for a single child across all caregivers)

/* Condensed spells */
DROP TABLE IF EXISTS #condensed_child_spells
GO

WITH
/* shared staging filter */
staging_spells AS (
	SELECT [child_snz_uid]
		,trim_start AS [start_date]
		,trim_end AS [end_date]
	FROM #parent_and_child_benefit
),
/* exclude start dates that are within another spell */
spell_starts AS (
	SELECT [child_snz_uid]
		, [start_date]
	FROM staging_spells s1
	WHERE NOT EXISTS (
		SELECT 1
		FROM staging_spells s2
		WHERE s1.[child_snz_uid] = s2.[child_snz_uid]
		AND DATEADD(DAY, -1, s1.[start_date]) BETWEEN s2.[start_date] AND s2.[end_date]
	)
),
/* exclude end dates that are within another spell */
spell_ends AS (
	SELECT [child_snz_uid]
		, [end_date]
	FROM staging_spells t1
	WHERE NOT EXISTS (
		SELECT 1 
		FROM staging_spells t2
		WHERE t2.[child_snz_uid] = t1.[child_snz_uid]
		AND  t1.[end_date] BETWEEN DATEADD(DAY, -1, t2.[start_date]) AND DATEADD(DAY, -1, t2.[end_date])
	)
)

SELECT s.[child_snz_uid]
	, s.[start_date] as [start_date]
	, MIN(e.[end_date]) as [end_date]
INTO #condensed_child_spells
FROM spell_starts AS s
INNER JOIN spell_ends AS e
	ON s.[child_snz_uid] = e.[child_snz_uid]
	AND s.[start_date] <= e.[end_date]
GROUP BY s.[child_snz_uid]
	, s.[start_date]
GO

CREATE NONCLUSTERED INDEX i_child ON #condensed_child_spells (child_snz_uid)
GO

-------------------------------------------------------------------------------
-- Calculate % days on benefit

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_parent_benefit_duration_$(REFRESH)]
GO

WITH trim_dates AS (

	SELECT c.child_snz_uid AS snz_uid
		, p.snz_birth_date_proxy
		, DATEADD(YEAR,18,p.snz_birth_date_proxy) AS birthday18_proxy
		, c.[start_date]
		, c.[end_date]
		, IIF(c.[start_date] < p.snz_birth_date_proxy, p.snz_birth_date_proxy, c.[start_date]) AS trim_start -- latest start date
		, IIF(c.[end_date] < DATEADD(YEAR,18,p.snz_birth_date_proxy), c.[end_date], DATEADD(YEAR,18,p.snz_birth_date_proxy)) AS trim_end -- eariest end date
	FROM #condensed_child_spells AS c
	INNER JOIN [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS p
		ON c.child_snz_uid = p.snz_uid
		-- payment range overlaps with child birth to 18th birthday
		AND p.snz_birth_date_proxy < c.[end_date]
		AND c.[start_date] < DATEADD(YEAR,18,p.snz_birth_date_proxy)
		AND c.[start_date] <= c.[end_date]

),
calculation AS (

	SELECT snz_uid
		-- sum as want cumulative over all benefit spells 
		, SUM(DATEDIFF(DAY, trim_start, trim_end)) AS days_benefit
		-- max as only want one copy of days from birth to 18th birthday/today
		, DATEDIFF(DAY, snz_birth_date_proxy, IIF(birthday18_proxy < GETDATE(), birthday18_proxy, GETDATE())) AS days_childhood -- crude max_date
	FROM trim_dates
	GROUP BY snz_uid
		, snz_birth_date_proxy
		, birthday18_proxy

)
SELECT snz_uid
	, IIF(days_benefit > days_childhood, 100.0,  ROUND(100.0 * days_benefit / days_childhood, 1)) AS perc_childhood_on_ben
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_parent_benefit_duration_$(REFRESH)]
FROM calculation
GO

/* Compress final table to save space */
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_parent_benefit_duration_$(REFRESH)]'

/* Add index */
CREATE NONCLUSTERED INDEX my_index_name ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_parent_benefit_duration_$(REFRESH)] (snz_uid);
GO

