/*****************************************

Cohort: Children with incarcerated parents - spells

SIF priority cohort -'Children whowith a parent currently or recently in prison'

The purpose of the spell view is to look at numbers and people in the cohort over time.

This indicator produces a list of children ids, of children who had a parent incarcerated after they were born. This includes both imprisonment and remand, for prison spells starting in or after 1996.

The final table records the childs snz_uid, the snz_uid of the parent, the birth date of the child, the start date of an incarceration spell (cohort 'entry') and the date the child 'exits' the cohort i.e 5 years after the incarceration end date, or the 18th birthday, whichever comes first.

The table includes overlapping spells, where a parent enters and exits prison multiple times within five years, as such this table is NOT suitable for calculating durations.

Outcomes: 
- incarceration can lead to instability in a child's life
- parental imprisonment can also alleviate exposure to fv and substance abuse
- children may have trauma from improsonment process and lack support in their lives

NOTES
- Data goes way back to 1600's supposedly, but reliable from 1980's
- Start with going back to 1996
- We do not record the earliest age/date for the child, when the parent was in prison. This is a yes/no indicator as at turning 12.
- Switching to the rebuilt definition maps some periods to ''. Joining to the corrections directives table produces about 4000 rows
	ending after 2020, most of which are imprisonment (approx: 40% remand / 30% life  / 10% preventive detention); with about 20% as parole. 
	However, the directives table can include overlapping rows, so these have not necessarily been excluded. SA has advised to treat
	the '' category as equivalent to non-prison management by corrections.

Author: Ashleigh Arendt
Date: 14-11-2024

History:
2025-08-19 CR added spell format
2025-08-05 DY Correct issues from temporary fix, modified to not exclude parent where the other is NULL, relaxed age restriction to <=17.
2025-07-09 DY Updated to refer to the rebuilt table for the 202506 refresh
2025-07-04 DY Updated to refer to the temp fix to the corrections table for the 202506 refresh


*****************************************/

DROP VIEW IF EXISTS [DL-MAA2023-46].[defn_cohort_CIP_spells_202506];
GO

CREATE VIEW [DL-MAA2023-46].[defn_cohort_CIP_spells_202506] AS 
WITH
incarcertation AS (

	SELECT a.[snz_uid]
		, mm_type AS [cor_rommp_directive_type]
		, [start_date] AS [cor_rommp_period_start_date]
		, [end_date] AS [cor_rommp_period_end_date]
	FROM [SIA_Sandpit].[DL-MAA2023-46].[def_COR_major_management_periods_202506] a
	WHERE year([start_date]) >= 1996 -- corrections start date is after 1996, but child birth year is from 1984
	AND mm_type IN ('IMPRISONMENT', 'REMAND') -- See note above
	AND [start_date] is not null
	AND [end_date] is not null -- open periods should be set to end as 9999-12-31
	-- AND [start_date] <= [end_date] -- not needed, this is checked in the table build

),
parent1 AS (

	SELECT b.snz_uid as child_snz_uid
	, snz_parent1_uid AS parent_snz_uid
	, snz_birth_date_proxy
	, a.cor_rommp_period_start_date as cohort_start
	, IIF(DATEADD(YEAR,5,a.cor_rommp_period_end_date) > DATEADD(YEAR, 18, b.snz_birth_date_proxy), DATEADD(YEAR, 18, b.snz_birth_date_proxy) ,DATEADD(YEAR,5,a.cor_rommp_period_end_date)) as cohort_end
	FROM incarcertation AS a
	INNER JOIN [IDI_Clean_202506].[data].[personal_detail] AS b
	ON a.snz_uid = b.snz_parent1_uid
	WHERE snz_parent1_uid IS NOT NULL
		AND (snz_parent1_uid <> snz_parent2_uid OR snz_parent2_uid IS NULL) -- exclude if parent1 = parent2 -- this means records listing one parent twice will never be included?
		AND a.cor_rommp_period_start_date < DATEADD(YEAR, 18, b.snz_birth_date_proxy) --prison start date was whilst the child was under 17
		AND a.cor_rommp_period_end_date >= b.snz_birth_date_proxy 

),
parent2 AS (
	SELECT b.snz_uid as child_snz_uid
		, snz_parent2_uid AS parent_snz_uid
		, snz_birth_date_proxy
		, a.cor_rommp_period_start_date as cohort_start
		, IIF(DATEADD(YEAR,5,a.cor_rommp_period_end_date) > DATEADD(YEAR, 18, b.snz_birth_date_proxy), DATEADD(YEAR, 18, b.snz_birth_date_proxy) ,DATEADD(YEAR,5,a.cor_rommp_period_end_date)) as cohort_end
	FROM incarcertation AS a
	INNER JOIN [IDI_Clean_202506].[data].[personal_detail] AS b
	ON a.snz_uid = b.snz_parent2_uid
	WHERE snz_parent2_uid IS NOT NULL
		AND (snz_parent1_uid <> snz_parent2_uid OR snz_parent1_uid IS NULL)-- exclude if parent1 = parent2
		AND a.cor_rommp_period_start_date < DATEADD(YEAR, 18, b.snz_birth_date_proxy) --prison start date was whilst the child was under 17
		AND a.cor_rommp_period_end_date >= b.snz_birth_date_proxy -- ever

)
SELECT * 
FROM parent1
UNION -- the UNION statement makes this an implicit distinct
SELECT *
FROM parent2;
GO

