/**************************************************************************************************
Title: NEET spells
Author: Charlotte Rose
Peer Review: 

Inputs & Dependencies:
- [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_202506] -- TO BE REPLACED WITH CODE MODULE

Outputs:
- [SIA_Sandpit].[DL-MAA2023-46].[defn_neet_spells_202506]


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
  Current refresh = 202506
  Prefix = defn_
  Project schema = [DL-MAA2023-46]
 
Issues:
1) 
 
History (reverse order):
2025-08-25: DY change to bring in bookends


**************************************************************************************************/


DROP TABLE IF EXISTS #bookended_EET;
GO


WITH prep AS (
	SELECT DISTINCT snz_uid
		,dob
		,'2025-01-01' AS start_date
		,DATEADD(YEAR,15,dob) AS END_DATE
		,'BKD' AS spell_type
		,NULL AS entity
	FROM [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_202506]),
prec AS (
	SELECT * FROM [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_202506]
	UNION
	SELECT * FROM prep)
SELECT *
INTO #bookended_EET
FROM prec

DROP TABLE IF EXISTS #EET_linked;
GO

WITH start_dates AS (
			SELECT snz_uid
					,dob
					,[start_date]
			FROM #bookended_EET a
			WHERE NOT EXISTS (SELECT 1 
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
			WHERE NOT EXISTS (SELECT 1 
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

--Create NEET spells 

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[defn_neet_spells_202506]

SELECT a.snz_uid
	,a.dob
	,DATEADD(DAY,1,a.linked_end) AS NEET_start_date
	,DATEADD(DAY,-1,MIN(b.linked_start)) AS NEET_end_date
	,DATEDIFF(DAY,DATEADD(DAY,1,a.linked_end),DATEADD(DAY,-1,MIN(b.linked_start))) as NEET_length
INTO [SIA_Sandpit].[DL-MAA2023-46].[defn_neet_spells_202506]
FROM #EET_linked AS a
	INNER JOIN #EET_linked AS b
ON a.snz_uid = b.snz_uid
	AND a.linked_end <= DATEADD(DAY,-2,b.linked_start) 
WHERE DATEDIFF(MONTH,a.dob,'2025-01-01') / 12 < 25 -- cutting off at 25 years
GROUP BY a.snz_uid,a.dob, a.linked_end;

---------------------------------------------------------------------
-- Tidy up
---------------------------------------------------------------------

DROP TABLE IF EXISTS #bookended_EET
DROP TABLE IF EXISTS #EET_linked

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2023-46].[defn_neet_spells_202506] (snz_uid)
GO
