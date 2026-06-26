/**************************************************************************************************
Title: NEET spells
Author: Charlotte Rose
Peer Review: 

Inputs & Dependencies:
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[EET_spells_$(REFRESH)] -- TO BE REPLACED WITH CODE MODULE

Outputs:
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_neet_spells_$(REFRESH)]


Description:

Creates NEET spells from the EET spells code module (currently the pre-deployment version at I:\MAA2023-46\projects\Commissioning cohorts\01 Shared definitions\CM_EET_FLEXIBLE.sql)

This includes people age 15 to 64 who are NOT

- In formal education
- In employment
- Overseas
- In prison
- Incapcaitated and therefore unable to work

NEET duration (of each spell), and dob are included for filtering purposes
 

Intended purpose:

 
Notes:
1) Maximum end date or 'current' is 2024-12-31. This is because it is the maximum date for MoE enrolment data (until the October refresh)

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
1) 
 
History (reverse order):
2025-11-06 SA cap spell ends with max_dates
2025-08-25: DY change to bring in bookends


**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"


DROP TABLE IF EXISTS #bookended_EET;
GO

-------------------------------------------------------------------------------
-- add bookend

WITH prep AS (
	SELECT DISTINCT snz_uid
		,dob
		,'2025-01-01' AS start_date
		,DATEADD(YEAR,15,dob) AS END_DATE
		,'BKD' AS spell_type
		,NULL AS entity
		FROM [IDI_Community].[emp_eet_flexible].[eet_flexible_$(REFRESH)]
),
prec AS (
	SELECT * FROM [IDI_Community].[emp_eet_flexible].[eet_flexible_$(REFRESH)]
	UNION
	SELECT * FROM prep
)
SELECT *
INTO #bookended_EET
FROM prec

-------------------------------------------------------------------------------
-- merge EET spells

DROP TABLE IF EXISTS #EET_linked;
GO

WITH start_dates AS (
	SELECT snz_uid
		,dob
		,[start_date]
	FROM #bookended_EET a
	WHERE NOT EXISTS (
		SELECT 1 
		FROM #bookended_EET  b 
		WHERE a.snz_uid = b.snz_uid 
		AND DATEADD(DAY, -1, a.start_date) <= b.end_date
		AND a.[start_date] > b.[start_date] 
	)
),
end_dates AS (
	SELECT snz_uid
		,dob
		,end_date
	FROM #bookended_EET a
	WHERE NOT EXISTS (
		SELECT 1 
		FROM #bookended_EET b 
		WHERE a.snz_uid = b.snz_uid 
		AND DATEADD(DAY, 1, a.end_date) >= b.start_date
		AND a.[end_date] < b.[end_date]
	)
)

SELECT a.snz_uid
	,a.dob
	,a.[start_date] AS [linked_start]
	,MIN(b.[end_date]) AS [linked_end]
INTO #EET_linked
FROM start_dates a
LEFT JOIN end_dates b
ON a.snz_uid = b.snz_uid
AND a.[start_date] <=b.end_date
GROUP BY a.snz_uid,a.dob,a.start_date;

-------------------------------------------------------------------------------
-- Invert EET to create NEET spells 

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_neet_spells_$(REFRESH)]

SELECT a.snz_uid
	,a.dob
	,DATEADD(DAY,1,a.linked_end) AS NEET_start_date
	,DATEADD(DAY,-1,MIN(b.linked_start)) AS NEET_end_date
	,DATEDIFF(DAY,DATEADD(DAY,1,a.linked_end),DATEADD(DAY,-1,MIN(b.linked_start))) as NEET_length
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_neet_spells_$(REFRESH)]
FROM #EET_linked AS a
INNER JOIN #EET_linked AS b
ON a.snz_uid = b.snz_uid
AND a.linked_end <= DATEADD(DAY,-2,b.linked_start) 
GROUP BY a.snz_uid,a.dob, a.linked_end;

---------------------------------------------------------------------
-- Tidy up
---------------------------------------------------------------------

DROP TABLE IF EXISTS #bookended_EET
DROP TABLE IF EXISTS #EET_linked

-- Compression
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_neet_spells_$(REFRESH)]'
GO

CREATE NONCLUSTERED INDEX i_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_neet_spells_$(REFRESH)] (snz_uid)
GO
