/**************************************************************************************************
Title: YORST scores for all offenders at time of Police proceeding
Author: Simon Anastasiadis

Inputs & Dependencies:
	[IDI_Clean].[pol_clean].[post_count_offenders]
Output:
	[IDI_Sandpit].[DL-MAA2023-46].[defn_yorst_score_at_police_proceeding_202506]	

Description:
YORST is the Youth Offending Risk Screening Tool
This code implements a simplified version based on three components of YORST
that can be observed in Police data in the IDI.

Notes:
- Three components of YORST score >> and their corresponding numeric score/value:
	1) Count of prior offences
		0, 1, 2, 3, 4+ >> 0, 0, 3, 3, 5
	2) Time between two most recent offences
		no previous, over 2 years, 24-12 months, 12-6 months, 6-1 month, <1 month >> 0, 1, 2, 3, 4, 5
	3) Age of first offense
		no previous, >14 years old, 14 years old, 13 years old, 10-12 years old, under 10 years old >> 0, 1, 2, 3, 4, 5
		(note as our analysis is based on Police proceedings against offenders, 'no previous' does not occur in our data)
- YORST is intended for Youth Offending
	We have calculated for all offending events for simplicity.
	When used, filtering to ages <18 is recommended.
- Main data source is Police Post Count Offenders.
	- This combines offences that are part of the same incident together. This is consistent with our method
	as otherwise an incident with more than one offence will show up as multiple offences all on the same day.
	- Using proceeding date rather than offence date as this is the point of interaction with police at which
	a YORST assessment can be completed.
- Records in the table have three uids: person, offence, and occurrence.
	Checking offence and occurrence uids:
	- An offence has only a single occurrence
	- An occurrence can have multiple offences (more than 20, though <5 is most common)
	This is consistent with the data dictionary where
	- an offence is a single chargable offence within a criminal incident
	- an occurrence is a single criminal incident (i.e. an event)
	Inspection of the data suggests that:
	- Every record has an occurrence uid and an offence uid
	- An occurrence can be shared by multiple people (e.g. several people commit a burglary)
	- An occurrence can have multiple offences (e.g. during the buglary one person also damaged property)
	- An occurrence can have multiple proceeding dates for different individuals (e.g. each offender is charged on a different date)
	- An occurrence can have multiple proceeding dates for the same individual (e.g. as more evidence is recovered, charges increase)
	
	Therefore, while post-count differs from pre-count in that offences from the same incident are merged together,
	this merging may require that the proceeding date is the same and/or that all offenders can be merged
	in the same way. We begin my taking the first proceeding date for an occurrence for each person.
- YORST scores were Adhoc loaded into the IDI at one point
	See the table [IDI_Adhoc].[clean_read_POL].[YORST_202312]
	We compared the approximate scores generated from this method against the observed scores in this Adhoc table:
	- The overarching distribution of scores is not a good match between the two. The approximation has
		a much higher proportion of low scores.
	- Linking between the two tables where the scores are calculated within a week or a fortnight of each other
		gives a correlation of 0.7. A scatter chart confirms a weak relationship with significant variation.
	- The proposal is to use 5+ as a threshold for the approximate scores.
		Just under 60% of approximate YORST scores we calculate have a value of 5+
		This is comparable to observed YORST scores around 42 (near 60% of observed YORST scores are 42+).
		Police YORST documentation classified a score of 30-69 as medium risk, this threshold covers
		most of the medium risk and all of the high risk people.	
- A comparison of NIA Links against Police Offenders suggests that in most cases there is minimal gap (most often 0 days)
	between the proceeding date and any NIA Link record from the same time period.
- In 202506 refresh, data is available up to March 2025
	General trend is downwards from around 600 proceedings a day in 2009 to around 300 a day in 2024 early 2025 .

Parameters & Present values:
  Current refresh = 202506
  Project schema = [DL-MAA2023-46]
 
Issues:
 
History (reverse order):
2025-07-15 CR updated to 202506 refresh 
2025-06-10 Dan Young QA
2025-06-06 SA version 1
**************************************************************************************************/

--------------------------------------------------------------------------------
-- Staging view
USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence]
GO

CREATE VIEW [DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence] AS
SELECT [snz_uid]
    ,[snz_pol_occurrence_uid]
    ,MIN([pol_poo_proceeding_date]) AS [pol_poo_proceeding_date]
FROM [IDI_Clean_202506].[pol_clean].[post_count_offenders]
WHERE [snz_person_ind] = 1 -- must be a person
AND [pol_poo_occurrence_inv_ind] = 1 -- investigation completed (1 = yes, 0 = no) value is always 1
AND [pol_poo_offence_inv_ind] = 1 -- offence recorded (1 = yes, 0 = no) metadata states values of zero are incomplete and should be treated with caution
AND [pol_poo_proceeding_code] <> 999 -- proceeding action is not 'unknown'
--AND [pol_poo_proceeding_code] <> 300 -- proceeding action is not 'not proceeded with'
GROUP BY [snz_uid], [snz_pol_occurrence_uid]
GO

--------------------------------------------------------------------------------
-- Count of prior offences
DROP TABLE IF EXISTS #count_prior_offences

SELECT a.snz_uid
	,a.[snz_pol_occurrence_uid]
    ,a.[pol_poo_proceeding_date]
	,COUNT(*) - 1 AS prior_offences
INTO #count_prior_offences
FROM [IDI_UserCode].[DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence] AS a
INNER JOIN [IDI_UserCode].[DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence] AS b
ON a.snz_uid = b.snz_uid -- same person
AND b.[pol_poo_proceeding_date] <= a.[pol_poo_proceeding_date] -- past offences
GROUP BY a.snz_uid
	,a.[snz_pol_occurrence_uid]
    ,a.[pol_poo_proceeding_date]
GO

--------------------------------------------------------------------------------
-- Time between two most recent offences
DROP TABLE IF EXISTS #time_since_last_offence

;WITH setup AS (

SELECT snz_uid
	,[snz_pol_occurrence_uid]
    ,[pol_poo_proceeding_date]
	,LAG([pol_poo_proceeding_date]) OVER (PARTITION BY snz_uid ORDER BY [pol_poo_proceeding_date], [snz_pol_occurrence_uid]) AS last_proceeding_date
FROM [IDI_UserCode].[DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence]

)
SELECT *
	,DATEDIFF(DAY, last_proceeding_date, [pol_poo_proceeding_date]) AS days_since_last_offence
INTO #time_since_last_offence
FROM setup
GO

--------------------------------------------------------------------------------
-- Age of first offense
DROP TABLE IF EXISTS #age_first_offence

SELECT a.snz_uid
	,b.snz_birth_date_proxy
	,MIN([pol_poo_proceeding_date]) AS earliest_offence
	,FLOOR(DATEDIFF(MONTH, b.snz_birth_date_proxy, MIN([pol_poo_proceeding_date])) / 12.0) AS age_at_first_offence
INTO #age_first_offence
FROM [IDI_UserCode].[DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence] AS a
INNER JOIN [IDI_Clean_202506].[data].[personal_detail] AS b
ON a.snz_uid = b.snz_uid
GROUP BY a.snz_uid, b.snz_birth_date_proxy
GO

--------------------------------------------------------------------------------
-- Index for ease of joining

CREATE NONCLUSTERED INDEX i_uid ON #count_prior_offences (snz_uid)
CREATE NONCLUSTERED INDEX i_uid ON #time_since_last_offence (snz_uid)
CREATE NONCLUSTERED INDEX i_uid ON #age_first_offence (snz_uid)
GO

--------------------------------------------------------------------------------
-- YORST score

DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA2023-46].[defn_yorst_score_at_police_proceeding_202506]
GO

WITH setup AS (

SELECT c.snz_uid
	,c.snz_pol_occurrence_uid
	,c.pol_poo_proceeding_date
	,c.prior_offences
	,t.last_proceeding_date
	,t.days_since_last_offence
	,a.earliest_offence
	,a.snz_birth_date_proxy
	,a.age_at_first_offence
	-- Count of prior offences
	-- 0, 1, 2, 3, 4+ >> 0, 0, 3, 3, 5
	,CASE
		WHEN prior_offences = 0 THEN 0
		WHEN prior_offences = 1 THEN 0
		WHEN prior_offences = 2 THEN 3
		WHEN prior_offences = 3 THEN 3
		WHEN prior_offences >= 4 THEN 5 END AS score_prior_offences
	-- Time between two most recent offences
	-- no previous, over 2 years, 24-12 months, 12-6 months, 6-1 month, <1 month >> 0, 1, 2, 3, 4, 5
	,CASE
		WHEN days_since_last_offence IS NULL THEN 0
		WHEN days_since_last_offence > 2*365 THEN 1
		WHEN days_since_last_offence > 365 THEN 2
		WHEN days_since_last_offence > 182 THEN 3
		WHEN days_since_last_offence > 30 THEN 4
		WHEN days_since_last_offence >= 0 THEN 5 END AS score_days_since_last_offense -- includes multiple offenses on same day
	-- Age of first offense
	-- 	no previous, >14 years old, 14 years old, 13 years old, 10-12 years old, under 10 years old >> 0, 1, 2, 3, 4, 5
	-- (as everyone has an offense by definition, first category is omitted)
	,CASE
		WHEN age_at_first_offence > 14 THEN 1
		WHEN age_at_first_offence >= 14 THEN 2
		WHEN age_at_first_offence >= 13 THEN 3
		WHEN age_at_first_offence >= 10 THEN 4
		WHEN age_at_first_offence BETWEEN 0 AND 12 THEN 5 END AS score_age_at_first_offence

FROM #count_prior_offences AS c
INNER JOIN #time_since_last_offence AS t
ON c.snz_uid = t.snz_uid
AND c.[snz_pol_occurrence_uid] = t.[snz_pol_occurrence_uid]
INNER JOIN #age_first_offence AS a
ON c.snz_uid = a.snz_uid

)
SELECT *
		,score_prior_offences + score_days_since_last_offense + score_age_at_first_offence AS yorst_score
INTO [IDI_Sandpit].[DL-MAA2023-46].[defn_yorst_score_at_police_proceeding_202506]
FROM setup
GO

CREATE NONCLUSTERED INDEX i_uid ON [IDI_Sandpit].[DL-MAA2023-46].[defn_yorst_score_at_police_proceeding_202506] (snz_uid, pol_poo_proceeding_date)

--------------------------------------------------------------------------------
-- Tidy up

DROP VIEW IF EXISTS [DL-MAA2023-46].[tmp_police_offences_earliest_proceeding_per_occurrence]
DROP TABLE IF EXISTS #count_prior_offences
DROP TABLE IF EXISTS #time_since_last_offence
DROP TABLE IF EXISTS #age_first_offence
