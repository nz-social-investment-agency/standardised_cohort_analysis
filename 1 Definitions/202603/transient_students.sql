/**************************************************************************************************
Title: Number of school moves
Author: Wian Lusse
Peer review: Charlotte Rose

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol]
- [IDI_Clean_$(REFRESH)].[moe_clean].[provider_profile]
- [IDI_Metadata_$(REFRESH)].[moe_school].[provider_type_code] 
- [IDI_Metadata_$(REFRESH)].[moe_school].[sch_region_code]
- max_date MOE student_enrol.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_enrol]

Outputs:
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[transient_students_$(REFRESH)]

Description:
Finding the number of students who have had more than two non-structural* school or kura moves. In this case we are not trimming to a time period (i.e within one year), rather 
looking across a all school years

*Structural moves are a movement between schools or kura forced by the structure of the schooling system 
(e.g. a student moving between primary and intermediate, or intermediate and secondary school)

Intended purpose:
This indicator shows the number of students who have had more than two non-structural school moves.

Research has found students who move schools OR kura regularly are more likely to underachieve in formal education compared 
with students with a more stable school life.

Notes:
1) 

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = _
  Project schema = [$(PROJECT_SCHEMA)]
  Earliest start date = '2018-01-01'

Issues:
- OT have a similar indicator (WEL-31 dev-enrol) where they look at the prev 12mo, do not take into account primary to secondary as a structural move and do not filter 
  for moves between Mar & Nov. OTs figures are slightyly higher than MoE, however reporting periods dont match

- MoE look at moves within the calendar year, between 1 Mar and 1 Nov.

- Our code looks at previous 12 months, moves within the school year (Mar - Nov), and not structural 
(e.g. not primary to intermediate or secondary, intermediate to secondary, home school/ te kura etc to mainstream or vice versa)

- We get ~35% lower numbers to OT for Q2 2021, ~30% less than MoEs annual figures when matched to our population

- School enrol table extraction appears to be annual in August, therefore will only be updated in October refreshes. Max enrolment dates (by complete quarter) for refreshes are below;
	202303 Q22022
	202306 Q22022
	202310 Q22023
	202403 Q22023
	202406 Q22023
	202410 Q22024
	202510 Q22025
	202603 Q22025

History (reverse order):
2025-11-06 SA cap open spells with max_date
2025-06 - WL adapted from RDP
**************************************************************************************************/ 

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_transient_students_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_transient_students_$(REFRESH)] AS
WITH max_date AS (
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_MOE_student_enrol_$(REFRESH)]
),
schoolspells AS(

    SELECT DISTINCT e.snz_uid
        , e.snz_moe_uid
        , e.moe_esi_entry_year_lvl_nbr
        , e.moe_esi_provider_code
        , c.ProviderTypeId
        , c.ProviderTypeDescription AS [school_type]
        , CAST(e.moe_esi_start_date AS DATE) AS [date_started]
		, CAST(e.moe_esi_end_date AS DATE) AS raw_moe_esi_end_date
		, CASE --imputing a dummy end date if still attending
			WHEN e.moe_esi_end_date IS NULL THEN max_date
			WHEN e.moe_esi_end_date > max_date THEN max_date
			ELSE CAST(e.moe_esi_end_date AS DATE)
			END AS [date_left]
        , e.moe_esi_extrtn_date AS [EXTRACT date]
		-- order schools for each sutdent by start date
		, ROW_NUMBER() OVER(PARTITION BY snz_uid ORDER BY e.moe_esi_start_date) AS [RANK]
    FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_enrol] AS e
    LEFT JOIN [IDI_Clean_$(REFRESH)].[moe_clean].[provider_profile] AS b
    ON e.moe_esi_provider_code = b.moe_pp_provider_code
    LEFT JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[provider_type_code] AS c
    ON b.moe_pp_provider_type_code = c.ProviderTypeId
	CROSS JOIN max_date
),
school_moves AS (
-- specify whether move was structural OR not.
	SELECT a.*
    , IIF(a.moe_esi_provider_code!=b.moe_esi_provider_code,1,0) AS any_move
    , CASE WHEN  a.moe_esi_provider_code!=b.moe_esi_provider_code AND (
		(b.ProviderTypeId = 10024 AND a.ProviderTypeId IN (10023, 10025, 10032, 10029, 10030, 10033) AND a.moe_esi_entry_year_lvl_nbr>=7) 
			-- start school is Y1-6, next school is Y1-8/7-8/7-10/7-13/1-13/9-13, moving into Y7 OR above
		OR (b.ProviderTypeId = 10023 AND a.ProviderTypeId IN (10032, 10029, 10030, 10033) AND a.moe_esi_entry_year_lvl_nbr>=9)
			-- start school is Y1-8, next school is Y7-10/7-13/1-13/9-13, moving into Y9 OR above
		OR (b.ProviderTypeId = 10025 AND a.ProviderTypeId IN (10032, 10029, 10030, 10033) AND a.moe_esi_entry_year_lvl_nbr>=9)
			-- start school is Y7-8, next school is Y7-10/7-13/1-13/9-13, moving into Y9 OR above
		OR (b.ProviderTypeId = 10032 AND a.ProviderTypeId IN (10029, 10030, 10033) AND a.moe_esi_entry_year_lvl_nbr>=11)
			-- start school is Y7-10, next school is Y7-13/1-13/9-13, moving into Y11 OR above
		OR ((b.moe_esi_provider_code IN (972,498) OR a.ProviderTypeId=10026) AND a.ProviderTypeId IN (10024, 10023, 10025, 10032, 10029, 10030, 10033))
			-- start school is home school, te kura, OR special school, moving into any mainstream school
		OR (b.ProviderTypeId IN (10024, 10023, 10025, 10032, 10029, 10030, 10033) AND (a.moe_esi_provider_code IN (972,498) OR a.ProviderTypeId=10026))
			-- start school is a mainstream school, moving into home school, te kura, OR special school
		) THEN 1 ELSE 0 END AS structural_move
    , CASE WHEN (a.school_type = 'Alternative Education Provider' OR b.school_type = 'Alternative Education Provider' ) 
			AND DATEDIFF(DAY, a.date_started, b.date_started) < 7 THEN 1 -- next school is alt Ed provider AND they started a new associated school within week of starting alt ed
			WHEN (a.school_type = 'Teen Parent Unit' OR b.school_type = 'Teen Parent Unit' ) 
			AND DATEDIFF(DAY, a.date_started, b.date_started) < 7 THEN 1 -- next school is Teen Parent Unit AND they started a new associated school within week of joining TPU
			ELSE 0 END AS multipurpose_school
FROM schoolspells AS a
LEFT JOIN schoolspells AS b
ON a.snz_uid = b.snz_uid
AND a.[RANK]-1 = b.[RANK]
)
SELECT *
FROM school_moves s
WHERE s.structural_move <> 1 --not a stuctural move
AND s.multipurpose_school <> 1 --not teen parent OR alt ed duplicate
AND s.any_move = 1 --must not be their first school
GO
