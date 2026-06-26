/*
Methodology for finding maximum date for a source dataset
Simon Anastasiadis
2025-03-19

Logic is:
1 - Discard future dates as errors
2 - Keep only records within the last five years (to minimse impact of changes in data collection on calculation)
3 - Count number of records on each date (very low counts will later imply incomplete data)
4 - Compute threshold for low counts = one-fifth x 25th-percentile of count
5 - Discard records with count below this threshold (official collection ends earlier but some few dates occur later)
6 - Take the latest remaining date

*/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[max_date_POL_pre_count_offenders_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[max_date_POL_pre_count_offenders_$(REFRESH)] AS
WITH uid_list AS (

	SELECT DISTINCT snz_uid
	FROM [IDI_Clean_$(REFRESH)].[data].[personal_detail]

),
count_each_date AS (

	SELECT CAST([pol_pro_proceeding_date] AS DATE) AS the_date
		, COUNT(*) AS num
	FROM [IDI_Clean_$(REFRESH)].[pol_clean].[pre_count_offenders]
	WHERE [pol_pro_proceeding_date] BETWEEN DATEADD(YEAR, -5, GETDATE()) AND GETDATE() -- events between now and five years ago
	GROUP BY CAST([pol_pro_proceeding_date] AS DATE) -- remove times if DATETIME

),
rolling_average AS (
	
	SELECT *
		,AVG(num) OVER (ORDER BY the_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling7dayavg
	FROM count_each_date

),
threshold_calculation AS (

	SELECT the_date
		,num
		,rolling7dayavg
		,0.2 * PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY rolling7dayavg) OVER () AS threshold
	FROM rolling_average

),
max_date AS (

	SELECT MAX(the_date) AS max_date
	FROM threshold_calculation
	WHERE num >= threshold

)
SELECT snz_uid, max_date
FROM uid_list
	,max_date
GO

