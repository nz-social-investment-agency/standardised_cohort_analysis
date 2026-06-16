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

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [DL-MAA2023-46].[max_date_MOH_pharmaceutical_202506]
GO

CREATE VIEW [DL-MAA2023-46].[max_date_MOH_pharmaceutical_202506] AS
WITH uid_list AS (

	SELECT DISTINCT snz_uid
	FROM [IDI_Clean_202506].[data].[personal_detail]

),
count_each_date AS (

	SELECT CAST([moh_pha_dispensed_date] AS DATE) AS the_date
		, COUNT(*) AS num
	FROM [IDI_Clean_202506].[moh_clean].[pharmaceutical]
	WHERE [moh_pha_dispensed_date] BETWEEN DATEADD(YEAR, -5, GETDATE()) AND GETDATE() -- events between now and five years ago
	GROUP BY CAST([moh_pha_dispensed_date] AS DATE) -- remove times if DATETIME

),
threshold_calculation AS (

	SELECT the_date
		,num
		,0.2 * PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY num) OVER () AS threshold
	FROM count_each_date

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

