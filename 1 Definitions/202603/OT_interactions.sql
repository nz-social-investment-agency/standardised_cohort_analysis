/**************************************************************************************************
Title: OT interactions
Author: Dan Young
Peer review: 

Inputs & Dependencies:
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_intakes_event] 
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_intakes_details]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_investgtns_event]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_investgtns_details]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_ev_cli_fgc_cys_f]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_dt_cli_fgc_cys_d]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_ev_cli_fwas_cys_f]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_dt_cli_fwas_cys_d]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_placements_event]
	[IDI_Clean_$(REFRESH)].[cyf_clean].[cyf_placements_details]

	[IDI_Community].[chld_placement_spell].[placement_spell]
	max_date CYF investigations.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_CYF_investigations]

Description:
Interactions with OT of four types:
Report of concern (CNP only), investigations, family group conferences, and placements.

Secondary output = Time in OT custody.

Notes:
1) These types of interactions are in escalating levels of seriousness.
	Reports of concern are recived by OT and either escalated to an investigation,
	added to a current file as additional information or no action is taken.
	Investigations occur before Family Group Conferences.
	Family Group Conferences occur before Placements.
	Not every investigation leads to a FGC.
	Not every FGC leads to a placement.

2) OT Placements can be overlapping, and hence are not suitable for counting days
	in OT custody / 'the care of the chief executive of Oranga Tamariki'.
	Hence this definition merges all placement spells into custody spells.

3) The FWA table records Hui-a-Whanau (FWA: Family-Whanau Agreement, which may be
	the result of such a hui). Previously a researcher from OT advised that this is
	effectively a FGC in a Maori cultural context. 
	OT combine these with FGCs in the CWM, treating these as equivalent. We have done
	so too.

4) From 202603 refresh onwards code modules were available for many of these concepts.
	As part of migrating we compared between our original method and code module.
	Differences noted below:
	> Reports of concern
		> code module and reports of concern use cases were perfect matches
		> code module includes some alternative flags for events that are not ROC.
	> Investigations
		> code module also includes YJ investigations. But there are fewer than 100 such records
		> code module also requires social_work_phase_uid matches when joining and that 
			event_type_wid_nbr IN ('3','4'). But these have no detectable effect on result.
		> code module also requires that findings were recorded. 'no abuse found' is considered a
			finding, so this just excludes investigations where the data is incomplete.
			Overall impact: a reduction in record count by ~1%
	> FGC and FWA
		> there are separate code modules for these two concepts, but we merge together
			hence these still appear in the view here.
		> code module for FGC excludes records with no held date.
	> Placements
		> we have counted placement records (pre-merging spells) but code module merges
			spells where person, business area, placement type, and carer are identical.
			Swapping to code module will reduce our counts of placements.
		> merging of spells allows for some overlaps where placement type or carer differs,
			hence for duration calculations we need to do our own merge.
			(a check showed an average of ~90 days overlap per person per year where overlaps occur
			this is too large a source of noise to ignore.)

Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = MAA2023-46

Issues: 


History (reverse order):
2026-04-08 SA replace reports of concern, investigations, placements, FGC and FWA with corresponding code modules
2025-11-06 SA cap end_date with max_Date
2025-10-24 SA custody added as extension for counting days
2025-08-01 DY Added FWA to the FGC as a FGC equivalent
2025-06-13 CR Added ROC based on OT logic from (upcoming) code module
2025-03-17 SA version 1 based on Dan Young's code
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_OT_interactions_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_OT_interactions_$(REFRESH)] AS 
SELECT [snz_uid]
    ,[fwa_business_area_type] AS area_type
    ,[fwa_signed_date] AS from_date
	,'FWA' AS event_type
FROM [IDI_Community].[chld_family_whanau_agreement].[family_whanau_agreement_$(REFRESH)]

UNION ALL

SELECT [snz_uid]
    ,[fgc_business_area_type] AS area_type
    ,[fgc_referral_date] AS from_date
    ,'FGC' AS event_type
FROM [IDI_Community].[chld_family_group_conference].[family_group_conference_$(REFRESH)]
GO

-------------------------------------------------------------------------------
-- Custody

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_OT_custody_$(REFRESH)]
GO

WITH max_date AS (
	-- there are several CYF/OT max_date tables, picked this one as investigations occur first
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_CYF_investigations_$(REFRESH)]
),
/* only placements */
placements AS (
	SELECT snz_uid
		, [from_date] AS [start_date]
		, IIF([to_date] < max_date, [to_date], max_date) AS [end_date]
	FROM [IDI_Community].[chld_placement_spell].[placement_spell_$(REFRESH)]
	CROSS JOIN max_date
),
/* exclude start dates that are within another spell */
possible_starts AS (
	SELECT snz_uid
		,[start_date]
	FROM placements  AS s1
	WHERE NOT EXISTS (
		SELECT 1
		FROM placements  AS s2
		WHERE s1.snz_uid = s2.snz_uid
		AND DATEADD(DAY, -1, s1.[start_date]) BETWEEN s2.[start_date] AND s2.[end_date]
	)
),
/* exclude end dates that are within another spell */
possible_ends AS (
	SELECT snz_uid
		,[end_date]
	FROM placements  AS e1
	WHERE NOT EXISTS (
		SELECT 1
		FROM placements  AS e2
		WHERE e1.snz_uid = e2.snz_uid
		AND e1.[end_date] BETWEEN DATEADD(DAY, -1, e2.[start_date]) AND DATEADD(DAY, -1, e2.[end_date])
	)
)
SELECT s.snz_uid
	,s.[start_date] AS custody_start_date
	,MIN(e.[end_date]) AS custody_end_date
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_OT_custody_$(REFRESH)]
FROM possible_starts AS s
INNER JOIN possible_ends AS e
ON s.snz_uid = e.snz_uid
AND s.[start_date] <= e.[end_date]
GROUP BY s.snz_uid
	,s.[start_date]
GO

-- Compression
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_OT_custody_$(REFRESH)]'
GO

CREATE NONCLUSTERED INDEX i_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_OT_custody_$(REFRESH)] (snz_uid)
GO
