/**************************************************************************************************
Title: Adverse Childhood Experiences
Author: Charlotte Rose
Reviewer: Simon Anastasiadis

Description:
Calculates Adverse Childhood Experiences (ACEs) before age 18:
	1. Physical abuse
	2. Sexual abuse
	3. Emotional abuse
	4. Physical neglect
	5. Emotional neglect
	6. Parental/household substance abuse
	7. Parental/household mental illness
	8. Parental/household incerceration
	9. Parental seperation
	10. Parental/household deomstic violence

Inputs & Dependencies:
- [IDI_Clean_202506].[data].[personal_detail]
- [IDI_Clean_202506].[data].[snz_res_pop] 
- [IDI_Clean_202506].[data].[person_relationship]
- [IDI_Clean_202506].[cor_clean].[muster]
- [IDI_Clean_202506].[cen_clean].[census_individual_2023]
- [IDI_Clean_202506].[cyf_clean].[cyf_placements_event]
- [IDI_Clean_202506].[cyf_clean].[cyf_placements_details]
- [IDI_Clean_202506].[moe_clean].[student_interventions]
- [IDI_Clean_202506].[pol_clean].[pre_count_offenders]
- [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] 
- [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_202506]
- [IDI_Community].[inc_support_paymt].[support_paymt_202506]
- [IDI_Community].[edu_sch_att_year].[sch_att_year_202506]
- [IDI_Community].[edu_highest_nqflevel_spells].[highest_nqflevel_spells_202506]
- [IDI_UserCode].[DL-MAA2023-46].[defn_mental_illness_202506] -- (MHA_combined_202506.sql)
- [IDI_UserCode].[DL-MAA2023-46].[defn_substance_abuse_202506] -- (MHA_combined_202506.sql)
- [IDI_UserCode].[DL-MAA2023-46].[defn_separation_202506] -- (separation_202506.sql)
- [IDI_UserCode].[DL-MAA2023-46].[defn_transient_students_202506] -- (transient_students_202506.sql)
- [IDI_Sandpit].[DL-MAA2023-46].[defn_parent_benefit_duration_202506] -- (parent_benefit_202506.sql)

Notes:
- Initial purpose: Identify children with a score of 6 or over who are at higher risk of poor outcomes
	Developed for Stand Tu cohort analysis.
- During development:
	- As we have had to combine the two types of neglect, we have added 'Time in care' as it is considered
	 in some research and 'extended ACE' - this brings the maximum score back to 10.
	- The extension to ACES for the Stand definition draws on Stands referral criteria, particularly those
	 realted to behaviour and potential hardship.

Parameters & Present values:
  Current refresh = 202506
  Prefix = defn_
  Project schema = [DL-MAA2023-46]
  Residence year range = 2017 to 2025
 
Issues:
 
History (reverse order):
2025-09-11 SA review and update for changes in code module names
2025-07-30 SA extend date range to 2017, convert to spells
2025-07-18 CR v1
**************************************************************************************************/

-------------------------------------------------------------------------------
-- Resident and under 18
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #pop

SELECT DISTINCT pd.snz_uid
	 , snz_birth_date_proxy
	 , DATEFROMPARTS(YEAR(srp_ref_date), 12, 31) AS ace_date
INTO #pop
FROM [IDI_Clean_202506].[data].[personal_detail] AS pd	
INNER JOIN [IDI_Clean_202506].[data].[snz_res_pop] AS a
ON a.snz_uid = pd.snz_uid
WHERE FLOOR(DATEDIFF(MONTH, pd.snz_birth_date_proxy, DATEFROMPARTS(YEAR(srp_ref_date), 12, 31)) / 12) BETWEEN 0 AND 17
AND YEAR(srp_ref_date) BETWEEN 2017 AND 2025
GO

-------------------------------------------------------------------------------
-- 1. Abuse - Physical
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_physical

SELECT DISTINCT a.snz_uid
	, 1 as abuse_physical
	, ace_date
INTO #abuse_physical
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_202506] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Physical_Abused'
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.abuse_finding_date ) / 12) BETWEEN 0 AND 17

UNION

SELECT DISTINCT a.snz_uid
	, 1 AS abuse_physical
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] AS a
INNER JOIN #pop AS p
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE a.victim_flag = 1
AND a.is_FV_flag = 1
/*Not neglect*/
	AND TRY_CAST(codification as INT) NOT BETWEEN 1771 AND 1788 --Neglect or ill-treatment of persons under care
	AND TRY_CAST(codification as INT) NOT BETWEEN 3711 AND 3719 --Neglect or ill-treatment of persons under care
	AND codification NOT LIKE 'Y06%' -- Neglect and abandonment
	AND codification <>'SN55Z' --NEGLECT AFFECTING CHILD NEC
	AND codification <> 'SN570' --NEGLECT OR ABANDONMENT
	AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.incident_start_date) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 2. Abuse - Sexual
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_sexual

SELECT DISTINCT a.snz_uid
	, 1 as abuse_sexual
	, ace_date
INTO #abuse_sexual
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_202506] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Sexual_Abused'
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.abuse_finding_date ) / 12) BETWEEN 0 AND 17

UNION

SELECT DISTINCT a.snz_uid
	, 1 AS abuse_sexual
	, ace_date

FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE a.victim_flag = 1 AND a.is_SV_flag = 1
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.incident_start_date ) / 12) BETWEEN 0 AND 17
GROUP BY a.snz_uid, ace_date
GO

-------------------------------------------------------------------------------
-- 3. Abuse - Emotional
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_emotional

SELECT a.snz_uid
	, 1 as abuse_emotional
	, ace_date
INTO  #abuse_emotional
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_202506] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Emotional_Abused'
	AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.abuse_finding_date ) / 12) BETWEEN 0 AND 17

UNION

SELECT a.snz_uid
	, 1 as abuse_emotional
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] AS a 
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE victim_flag = 1
	AND codification = 'SN550' -- EMOTIONAL MALTREATMENT OF CHILD
	AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.incident_start_date ) / 12) BETWEEN 0 AND 17
GO
-------------------------------------------------------------------------------
-- 4. Neglect
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #neglect

SELECT a.snz_uid
	, 1 as neglect
	, ace_date
INTO #neglect
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_202506] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Neglect'
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.abuse_finding_date ) / 12) BETWEEN 0 AND 17

UNION

SELECT a.snz_uid
	, 1 as neglect
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] AS a 
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE victim_flag = 1
	AND (TRY_CAST(codification AS INT) BETWEEN 1771 AND 1788 --Neglect or ill-treatment of persons under care
		OR TRY_CAST(codification AS INT) BETWEEN 3711 AND 3719 --Neglect or ill-treatment of persons under care
		OR codification LIKE 'Y06%' -- Neglect and abandonment
		OR codification = 'SN55Z' --NEGLECT AFFECTING CHILD NEC
		OR codification = 'SN570') --NEGLECT OR ABANDONMENT
	AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.incident_start_date ) / 12) BETWEEN 0 AND 17
GO
-------------------------------------------------------------------------------
-- 5. Parental Mental Illness
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #mental_illness_parent

SELECT DISTINCT p.snz_uid
    , 1 AS mental_illness_parent
	, ace_date
INTO #mental_illness_parent
FROM [IDI_UserCode].[DL-MAA2023-46].[defn_mental_illness_202506] AS a
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON a.snz_uid = r.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid
	AND r.prl_relationship_type_code = 'CH'
	AND a.event_date <= p.ace_date
WHERE p.snz_birth_date_proxy < a.event_date  --in lifetime
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.event_date ) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 6. Parental Substance Abuse
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #substance_abuse_parent

SELECT DISTINCT p.snz_uid
    , 1 AS substance_abuse_parent
	, ace_date
INTO #substance_abuse_parent
FROM [IDI_UserCode].[DL-MAA2023-46].[defn_substance_abuse_202506] AS a
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON a.snz_uid = r.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid
	AND r.prl_relationship_type_code = 'CH'
	AND a.event_date <= p.ace_date
WHERE p.snz_birth_date_proxy < a.event_date  --in lifetime
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.event_date ) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 7. Parental Inceration
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #incarceration_parent

SELECT DISTINCT p.snz_uid
	, 1 AS incarceration_parent
	, ace_date
INTO #incarceration_parent
FROM [IDI_Clean_202506].[cor_clean].[muster] AS a
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r 
	ON a.snz_uid = r.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid 
	AND r.prl_relationship_type_code = 'CH'
	AND a.cor_mus_muster_start_date <= p.ace_date
	AND a.cor_mus_muster_end_date > p.snz_birth_date_proxy --in lifetime
	AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.cor_mus_muster_start_date ) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 8. Domestic Violence
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Domestic_violence_parent

SELECT p.snz_uid
	, 1 as Domestic_violence_parent
	, ace_date
INTO #Domestic_violence_parent
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506] AS a 
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON a.snz_uid = r.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid
	AND r.prl_relationship_type_code = 'CH'
	AND a.incident_start_date <= p.ace_date
	AND a.incident_end_date > p.snz_birth_date_proxy --in lifetime
WHERE is_FV_flag = 1
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.incident_start_date ) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 9. Parental Seperation
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #parental_separation

SELECT p.snz_uid
	, 1 as parental_separation
	, ace_date
INTO #parental_separation
FROM [IDI_UserCode].[DL-MAA2023-46].[defn_separation_202506] AS a
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON a.snz_uid = r.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid 
	AND r.prl_relationship_type_code = 'CH'
	AND a.end_date <= p.ace_date
WHERE FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.end_date) / 12) BETWEEN 0 AND 17

UNION

SELECT DISTINCT p.snz_uid
	 , MAX(CASE WHEN b.[income_source] = 'Sole Parent Support' THEN 1 
	 ELSE NULL END) as parental_separation
	, ace_date
FROM  [IDI_Community].[inc_support_paymt].[support_paymt_202506] b
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON r.snz_uid = b.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid
	AND r.prl_relationship_type_code = 'CH'
	AND b.period_end_date <= p.ace_date
WHERE FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, b.period_end_date) / 12) BETWEEN 0 AND 17
GROUP BY p.snz_uid, ace_date

UNION

SELECT DISTINCT p.snz_uid
	 , MAX(CASE WHEN cen.cen_ind_family_role_code IN (2,21) THEN 1
			ELSE NULL END) as parental_separation
	, ace_date
FROM [IDI_Clean_202506].[cen_clean].[census_individual_2023] cen
INNER JOIN [IDI_Clean_202506].[data].[person_relationship] r
	ON r.snz_uid = cen.snz_uid
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_associated_uid
	AND r.prl_relationship_type_code = 'CH'
	AND r.prl_ceased_date <= p.ace_date
WHERE p.snz_birth_date_proxy < '2023-03-31' --census period
GROUP BY p.snz_uid, ace_date
GO

-------------------------------------------------------------------------------
-- 10. Experience of care //this is an extended ACE//
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #time_in_care

SELECT p.snz_uid
    , 1 as time_in_care
	, ace_date
INTO #time_in_care
FROM [IDI_Clean_202506].[cyf_clean].[cyf_placements_event] plc
INNER JOIN [IDI_Clean_202506].[cyf_clean].[cyf_placements_details] ind 
	ON ind.snz_composite_event_uid = plc.snz_composite_event_uid
INNER JOIN #pop AS p
	ON p.snz_uid = plc.snz_uid
	AND plc.cyf_ple_event_from_date_wid_date <= p.ace_date
WHERE ind.cyf_pld_business_area_type_code = 'CNP'
AND FLOOR(DATEDIFF(MONTH, snz_birth_date_proxy, plc.cyf_ple_event_from_date_wid_date) / 12) BETWEEN 0 AND 17
GO

-------------------------------------------------------------------------------
-- 11. Behavioural concenrs
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #behaviour_concern

/*
Metadata:
InterventionID	InterventionName
6	Alternative Education
7	Suspension (this includes expulsions and exclusions)
8	Stand down
*/

SELECT a.snz_uid
   , 1 as behaviour_concern
   , ace_date
INTO #behaviour_concern
FROM [IDI_Clean_202506].[moe_clean].[student_interventions] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND a.moe_inv_start_date <= p.ace_date
WHERE [moe_inv_intrvtn_code] IN (6,7,8)
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.moe_inv_start_date) / 12) <= 17

UNION

SELECT  a.snz_uid
    , 1 as behaviour_concern
	, ace_date
FROM [IDI_Clean_202506].[pol_clean].[pre_count_offenders] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND pol_pro_earliest_occ_start_date <= p.ace_date
WHERE FLOOR(DATEDIFF(MONTH, snz_birth_date_proxy, pol_pro_earliest_occ_start_date) / 12) <= 17
GO
-------------------------------------------------------------------------------
--12. Education disengagement
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #edu_disengage
/*
Metadata:
InterventionID	InterventionName
9	Non Enrolment Truancy Service
32	Truancy (Unjustified Absence)
*/

SELECT DISTINCT a.snz_uid
	, 1 as edu_disengage
	, ace_date
INTO #edu_disengage
FROM [IDI_Clean_202506].[moe_clean].[student_interventions] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND a.moe_inv_start_date <= p.ace_date
WHERE [moe_inv_intrvtn_code] IN (9,32)
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.moe_inv_start_date) / 12) <= 17

UNION

SELECT p.snz_uid
	, 1 as edu_disengage
	, ace_date
FROM [IDI_UserCode].[DL-MAA2023-46].[defn_transient_students_202506] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND a.date_started <= p.ace_date
GROUP BY p.snz_uid, ace_date
HAVING COUNT(*) >= 2 --two or more non-structural school moves, ever
 
UNION

SELECT a.[snz_uid]
	, 1 AS edu_disengage
	, ace_date
FROM [IDI_Community].[edu_sch_att_year].[sch_att_year_202506] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND a.[year] <= YEAR(p.ace_date)
	AND [attendance] = 'Chronic Absence' -- any year marked as chronic absence
GO
-------------------------------------------------------------------------------
--14. Low income
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #parent_long_term_benefit

SELECT p.snz_uid
	, 1 AS parent_long_term_benefit
	, ace_date
INTO #parent_long_term_benefit
FROM [IDI_Sandpit].[DL-MAA2023-46].[defn_parent_benefit_duration_202506] AS a -- this defn cuts of at 17th birthday so no need to filter in WHERE
INNER JOIN #pop AS p  
	ON a.child = p.snz_uid
	-- no date value as perc_childhood_on_ben is observed over lifetime
WHERE perc_childhood_on_ben >= 50
GO	
-------------------------------------------------------------------------------
--12. Maternal (birth mother) qualification
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #mother_no_qual

SELECT p.snz_uid
	, 1 AS mother_no_qual
	, ace_date
INTO #mother_no_qual
FROM #pop AS p
INNER JOIN [IDI_Clean_202506].[data].[personal_detail] pd
ON pd.snz_uid = p.snz_uid
LEFT JOIN [IDI_Community].[edu_highest_nqflevel_spells].[highest_nqflevel_spells_202506] h 
	ON h.snz_uid = pd.snz_parent1_uid
	AND h.nqf_attained_date <= p.ace_date
WHERE h.max_nqflevel_sofar = 0
OR max_nqflevel_sofar IS NULL
GO
-------------------------------------------------------------------------------
-- Final expanded table for Stand
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS [IDI_Sandpit].[DL-MAA2023-46].[defn_generalised_ACE_scores_202506]
GO

WITH add_indicators AS (

	SELECT DISTINCT p.snz_uid
		, p.ace_date
		, snz_birth_date_proxy
		--Abuse
		, COALESCE(a.abuse_physical , 0) AS abuse_physical
		, COALESCE(b.abuse_emotional , 0) AS abuse_emotional
		, COALESCE(c.abuse_sexual, 0) AS abuse_sexual
		--Neglect
		, COALESCE(d.neglect, 0) AS neglect
		--Parental 
		, COALESCE(e.mental_illness_parent, 0) AS mental_illness_parent
		, COALESCE(f.substance_abuse_parent, 0) AS substance_abuse_parent
		, COALESCE(g.incarceration_parent, 0) AS incarceration_parent
		, COALESCE(h.parental_separation, 0) AS parental_separation
		, COALESCE(j.domestic_violence_parent, 0) AS domestic_violence_parent
		, COALESCE(k.time_in_care, 0) AS time_in_care
		--extended for Stand
		, COALESCE(m.behaviour_concern, 0) AS behaviour_concern
		, COALESCE(n.edu_disengage, 0) AS edu_disengage
		, COALESCE(q.parent_long_term_benefit, 0) AS parent_long_term_benefit
		, COALESCE(r.mother_no_qual, 0) AS mother_no_qual

	FROM #pop AS p
	LEFT JOIN #abuse_physical AS a
		ON p.snz_uid = a.snz_uid
		AND p.ace_date = a.ace_date
	LEFT JOIN #abuse_emotional AS b
		ON p.snz_uid = b.snz_uid
		AND p.ace_date = b.ace_date
	LEFT JOIN #abuse_sexual AS c
		ON p.snz_uid = c.snz_uid
		AND p.ace_date = c.ace_date
	LEFT JOIN #neglect AS d
		ON p.snz_uid = d.snz_uid
		AND p.ace_date = d.ace_date
	LEFT JOIN #mental_illness_parent AS e
		ON p.snz_uid = e.snz_uid
		AND p.ace_date = e.ace_date
	LEFT JOIN #substance_abuse_parent AS f
		ON p.snz_uid = f.snz_uid
		AND p.ace_date = f.ace_date
	LEFT JOIN #incarceration_parent AS g
		ON p.snz_uid = g.snz_uid
		AND p.ace_date = g.ace_date
	LEFT JOIN #parental_separation AS h
		ON p.snz_uid = h.snz_uid
		AND p.ace_date = h.ace_date
	LEFT JOIN #Domestic_violence_parent AS j
		ON p.snz_uid = j.snz_uid
		AND p.ace_date = j.ace_date
	LEFT JOIN #time_in_care AS k
		ON p.snz_uid = k.snz_uid
		AND p.ace_date = k.ace_date
	LEFT JOIN #behaviour_concern AS m
		ON p.snz_uid = m.snz_uid
		AND p.ace_date = m.ace_date
	LEFT JOIN #edu_disengage AS n
		ON p.snz_uid = n.snz_uid
		AND p.ace_date = n.ace_date
	LEFT JOIN #parent_long_term_benefit AS q
		ON p.snz_uid = q.snz_uid
		AND p.ace_date = q.ace_date
	LEFT JOIN #mother_no_qual AS r
		ON p.snz_uid = r.snz_uid
		AND p.ace_date = r.ace_date
)
SELECT *
	   ,abuse_physical
		+ abuse_emotional
		+ abuse_sexual
		+ neglect
		+ mental_illness_parent
		+ substance_abuse_parent
		+ incarceration_parent
		+ parental_separation
		+ domestic_violence_parent
		+ time_in_care	
		+ behaviour_concern
		+ edu_disengage
		+ parent_long_term_benefit
		+ mother_no_qual
		AS ACE_score
INTO [IDI_Sandpit].[DL-MAA2023-46].[defn_generalised_ACE_scores_202506]
FROM add_indicators
GO

-- Compress and index
ALTER TABLE [IDI_Sandpit].[DL-MAA2023-46].[defn_generalised_ACE_scores_202506] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
GO

CREATE NONCLUSTERED INDEX ace_uid ON [IDI_Sandpit].[DL-MAA2023-46].[defn_generalised_ACE_scores_202506]  (snz_uid)
GO

/*-----------------TESTING--------------------

SELECT ACE_score
	,COUNT( distinct snz_uid)
	,COUNT(distinct snz_uid)*100.00 / (SELECT COUNT(snz_uid) FROM [IDI_Sandpit].[DL-MAA2023-46].[defn_ACE_scores] WHERE FLOOR(DATEDIFF(MONTH,snz_birth_date_proxy,'2025-03-31') / 12) = 12)
	FROM [IDI_Sandpit].[DL-MAA2023-46].[defn_ACE_scores] 
	WHERE FLOOR(DATEDIFF(MONTH,snz_birth_date_proxy,'2025-03-31') / 12) = 12
	GROUP BY ACE_score
	ORDER BY ACE_score


	SELECT ACE_score
	,COUNT( distinct snz_uid)
	,COUNT(distinct snz_uid)*100.00 / (SELECT COUNT(snz_uid) FROM [IDI_Sandpit].[DL-MAA2023-46].[Stand_generalised_ACE_scores])
	FROM [IDI_Sandpit].[DL-MAA2023-46].[Stand_generalised_ACE_scores] 
	GROUP BY ACE_score
	ORDER BY ACE_score

*/
