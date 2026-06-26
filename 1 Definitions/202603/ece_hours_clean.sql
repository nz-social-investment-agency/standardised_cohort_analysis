/**************************************************************************************************
Title: Clean ECE attendance
Author: Charlotte Rose
Peer review: Simon Anastasiadis

Inputs & Dependencies:
-[IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance]
 
Outputs:
[IDI_UserCode].[DL-MAA2020-61].[defn_ECE_clean_$(REFRESH)]

Description:
Some ECE attendance records significantly overlap on a single day. It is asusmed that this is
 due to differences in recording practices across different providers. In order to get a better
 idea of 'actual' hours this script merges overlapping spells and re-calculated attendance duration.

Intended purpose:
Trimming ECE attendance days to avoid long durations where attendence records overlap

Notes:
1) Only includes children marked as present


Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
  Earliest start date = 2015
 
Issues: 
-
  
Runtime: ~ 00:35:00

History (reverse order):
2026-04-23 SA merge into production pipeline
2026-04-09 - CR 
**************************************************************************************************/

-- :SETVAR PROJECT_DB "$(PROJECT_DB)"
-- :SETVAR PROJECT_SCHEMA "$(PROJECT_SCHEMA)"
-- :SETVAR REFRESH "$(REFRESH)"

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)]
GO

CREATE TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)] (
	snz_uid INT NOT NULL
	,moe_esa_attendance_date DATE NOT NULL
	,start_time TIME NOT NULL
	,end_time TIME NOT NULL
	,duration_mins INT 
	,duration_hrs FLOAT 
	,moe_esa_provider_code INT NULL
)
GO

ALTER TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)] REBUILD WITH (DATA_COMPRESSION = PAGE);
GO

/*Find children who with multiple record in a single day*/
WITH multi as (
	SELECT a.snz_uid
		, a.moe_esa_attendance_date 
	FROM [IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance] AS a
	WHERE YEAR(a.moe_esa_attendance_date) >= 2015
	AND a.moe_esa_ece_attendance_code = 'PRESENT'
	GROUP BY a.snz_uid
		, a.moe_esa_attendance_date 
	HAVING COUNT(*) > 1 --children with multiple ECE records on one day
)

/*transform date and times to datetime */
, staging_spells AS (
	SELECT a.snz_uid
		, a.moe_esa_attendance_date
		, CAST(CONCAT(a.moe_esa_attendance_date,' ',a.moe_esa_start_time) AS DATETIME2) AS start_datetime
		, CAST(CONCAT(a.moe_esa_attendance_date,' ',a.moe_esa_end_time) AS DATETIME2) AS end_datetime
		, a.moe_esa_provider_code
	FROM [IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance] AS a
	INNER JOIN multi AS m
	ON a.snz_uid = m.snz_uid
	AND a.moe_esa_attendance_date = m.moe_esa_attendance_date
)

/* exclude start datetimes that are within another spell */
,spell_starts AS (
	SELECT snz_uid
		, a.moe_esa_attendance_date
		, a.start_datetime AS start_trim
	FROM staging_spells AS a
	WHERE NOT EXISTS (
		SELECT 1 
		FROM staging_spells AS b
		WHERE a.snz_uid = b.snz_uid 
		AND a.start_datetime <= b.end_datetime
		AND a.start_datetime > b.start_datetime 
	)
)

/* exclude end datetimes that are within another spell */
,spell_ends AS (
	SELECT snz_uid
		, a.moe_esa_attendance_date
		, end_datetime AS end_trim
	FROM staging_spells AS a
	WHERE NOT EXISTS (
		SELECT 1 
		FROM staging_spells AS b 
		WHERE a.snz_uid = b.snz_uid 
		AND a.end_datetime >= b.start_datetime
		AND a.end_datetime < b.end_datetime
	)
)

/*condense spells*/
,ece AS (
	SELECT s.snz_uid	
		, s.moe_esa_attendance_date
		, s.start_trim as start_datetime
		, MIN(e.end_trim) as end_datetime
	FROM spell_starts AS s
	INNER JOIN spell_ends AS e
	ON s.snz_uid = e.snz_uid
	AND s.start_trim <= e.end_trim
	AND s.moe_esa_attendance_date = e.moe_esa_attendance_date --ensure on the same day
	GROUP BY s.snz_uid, s.moe_esa_attendance_date, s.start_trim
)

/*add back in those who only attended one ECE per day*/
, single AS ( 
	SELECT a.snz_uid
		, a.moe_esa_attendance_date 
	FROM [IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance] a
	WHERE YEAR(a.moe_esa_attendance_date) >= 2015-- just to shrink table
	AND a.moe_esa_ece_attendance_code = 'PRESENT'
	GROUP BY a.snz_uid
		, a.moe_esa_attendance_date 
	HAVING COUNT(*) = 1 
)

/* final table */
INSERT INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)] (snz_uid, moe_esa_attendance_date, start_time,end_time,duration_mins,duration_hrs,moe_esa_provider_code)

SELECT e.snz_uid
	, e.moe_esa_attendance_date
	, CAST(e.start_datetime AS TIME) as start_time
	, CAST(e.end_datetime AS TIME) as end_time
	, DATEDIFF(MINUTE,e.start_datetime, e.end_datetime) as duration_mins
	, DATEDIFF(MINUTE,e.start_datetime, e.end_datetime) / 60.0 as duration_hrs
	, a.moe_esa_provider_code
FROM ece AS e
INNER JOIN (
	SELECT snz_uid
		, start_datetime
		, MAX(moe_esa_provider_code) AS moe_esa_provider_code -- for simplicity, take one provider per spell
	FROM staging_spells
	GROUP BY snz_uid
		, start_datetime
) AS a
ON e.snz_uid = a.snz_uid
AND e.start_datetime = a.start_datetime

UNION ALL

SELECT a.snz_uid
	, a.moe_esa_attendance_date 
	, a.moe_esa_start_time AS start_time
	, a.moe_esa_end_time AS end_time
	, a.moe_esa_duration AS duration_mins
	, a.moe_esa_duration / 60.0 AS duration_hrs
	, a.moe_esa_provider_code
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[ece_student_attendance] a
INNER JOIN single AS s
ON a.snz_uid = s.snz_uid
AND a.moe_esa_attendance_date = s.moe_esa_attendance_date
AND a.moe_esa_ece_attendance_code = 'PRESENT'
GO

CREATE NONCLUSTERED INDEX ece_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_ECE_clean_$(REFRESH)] (snz_uid)
GO
