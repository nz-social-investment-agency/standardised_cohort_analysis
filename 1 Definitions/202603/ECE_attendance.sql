/**************************************************************************************************
Title: ECE attendance
Author: Simon Anastasiadis
Edited by Dan Young & Charlotte Rose

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance]
Outputs:
- [$(PROJECT_DB)].[DL-MAA2023-55].[defn_ece_attendance]

Description:
Recorded attendance at an ECE centre

Intended purpose:
Identifying who has attended Early Childhood Education, when they attended and the hours on average per week they attended.

Notes:
1) ECE attendance has been binned to 10-hour wide bins, those with 0 or NULL hours, but marked as 'present' have been grouped into an unknown hours category
2) There may be some inaccuracy at the margins as there will be periods where ECEs are not open. Desktop research suggests that many
   will have terms/holiday periods aligned with primary schools. This has 380-390 half days per year, across four terms.
   Terms appear to be roughly aligned with a quarter, but there may be some cross-over. Precise calculation would also need to take into
   account things like teacher-only days and any difference in the timing of regional holidays (eg, Auckland Anniversary Day is observed 
   in Q1 (January); Hawke's Bay Anniversary Day is observed in Q4 (October)) that could result in different distribution of opening 
   across the year.
3) As a result, this should not be used for very fine distinctions. Researchers using this code could look at the number of people close to the cut-off to
   consider if the binning is appropriate for their purposes.
4) Note from MoE - data in IDI and in PIM (Participation Intensity Measure) are sources from the ELI (Early Learning Information - a series of databases which 
   holds data primarily on enrolment and participation appolication, trying to reconcile the two would be difficult and not advised primarily due to the 
   complexity and construction of the PIM. Also noting that ELI is alive system and extracts taken at different times will differ. Thus this has not been reconciled and will be caveated as above
5) The oldest age in the quarter has been used
6) Will not match ECE census data as census can double count people attending multiple ECEs, and IDI does not contain data for all ECE types i.e playgroups, Kohanga Reo services etc (see IDI metadata)
7) As per 4) and 6) this has not been reconciled and will be caveated as above

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
  Earliest start date = '2018-01-01'

Issues:


History (reverse order):
2024-07-15 CR added age filter when adding to master to filter out those over 5yr
2023-01-15 CR updates for Regional Data Project
2022-04-05 JG Updated project and refresh for Data for Communities
2020-05-25 SA v1
**************************************************************************************************/

--:SETVAR PROJECT_DB "SIA_Sandpit"
--:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
--:SETVAR REFRESH "202603"


USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_ECE_attendance_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_ECE_attendance_$(REFRESH)] AS
SELECT a.[snz_uid]
    --, a.[snz_moe_uid]
    , a.[moe_esa_provider_code] AS [ProviderNumber]
    , a.[moe_esa_attendance_date] AS [AttendanceDate]
    , COALESCE(a.duration_mins,0) AS Duration
	, a.[moe_esa_provider_code]
FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)] AS a
GO
