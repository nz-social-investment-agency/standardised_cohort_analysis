/**************************************************************************************************
Title: Adverse Childhood Experiences
Author: Charlotte Rose
Reviewer: Lexi Xu

Description:
Calculates Adverse Childhood Experiences (ACEs) before age 18:

Conventional ACES are the following 10 experiences:
	1. Physical abuse
	2. Sexual abuse
	3. Emotional abuse
	4. Physical neglect
	5. Emotional neglect
	6. Parental/household substance abuse
	7. Parental/household mental illness
	8. Parental/household incerceration
	9. Parental seperation
	10. Parental/household doemstic violence

Given defining Physical neglect and Emotional neglect independently in the IDI is impossible, we have combined these two, and added 'time in care (OT custody) as the 10th ACE. This is used internationally as an 'extended ACE'

Our final ACEs then are:

	1. Physical abuse
	2. Sexual abuse
	3. Emotional abuse
	4. Neglect
	5. Parental/household substance abuse
	6. Parental/household mental illness
	7. Parental/household incerceration
	8. Parental seperation
	9. Parental/household domestic violence
	10. Experience of Oranga Tamariki care


Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[data].[personal_detail]
- [IDI_Clean_$(REFRESH)].[data].[snz_res_pop] 
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] -- (child_parent_caregiver.sql)
- [IDI_Community].[chld_placement_spell].[placement_spell_$(REFRESH)]
- [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] 
- [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_$(REFRESH)]
- [IDI_Community].[inc_support_paymt].[support_paymt_$(REFRESH)]
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_corrections_any_$(REFRESH)] -- (any_corrections_spells.sql)
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_mental_illness_$(REFRESH)] -- (MHA_combined_$(REFRESH).sql)
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_substance_abuse_$(REFRESH)] -- (MHA_combined_$(REFRESH).sql)
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_separation_$(REFRESH)] -- (separation_$(REFRESH).sql)
- [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511]


Notes:
1) % of children with a parent or caregiver in the data increases from 78% (2000 birth year) to 99% (2024 birth year) 
so the distribution of higher ACE scores will increase over time as many are parental-based

2) ACES score distribution has been tested against:
	- the Centers for disease control's original study on ACES (cohort of 18-year-olds from 1995-1999) with IDI 18 year olds in 2025
	- Growing up in New Zealand study on ACES (cohort of 4.5-year-olds from 2009-2015) with IDI 5 year olds in 2009-2015
		- this was done with a slightly amended set of ACEs, see ACE_test_GUiNZ.sql

Distributions acorss both test sets are broadly complarable, however we see discrete differences in the number of children with 0 ACES (higher in IDI)

We also see more children with 4+ ACES when comparing to the Growing Up in New Zealand study.

We think that the differences are mostly due to the differences in admin data versus self reported data

For example, we see much lower rates of physical and emotional abuse in the IDI, but much higher rates of parental family violence 

For detailed validation details, see ACE_score_validation.xlsx
	

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]

 
Issues:
 
History (reverse order):
2026-05-12 CR update to follow generalised_ACE improvements, tested and confirmed reproduced
2026-04-07 SA update to code module with view
2026-04-01 CF updated refresh to 202603
2025-12-22 CR added in-utero exposure to parental substance abuse, and abuse codes from Gateway
2025-12-12 CR Added child_parent definition to replace person_relationship to include more parents/caregivers
2025-09-11 SA review and update for changes in code module names
2025-07-30 SA extend date range to 2017, convert to spells
2025-07-18 CR v1
**************************************************************************************************/

--:SETVAR PROJECT_DB "SIA_Sandpit"
--:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
--:SETVAR REFRESH "202603"


-------------------------------------------------------------------------------
-- Resident and under 18
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #pop
GO

CREATE TABLE #pop (
	snz_uid INT NOT NULL
	,snz_birth_date_proxy DATE NOT NULL
	,ace_date DATE NOT NULL
	,abuse_physical TINYINT
	,abuse_sexual TINYINT
	,abuse_emotional TINYINT
	,neglect TINYINT
	,mental_illness_parent TINYINT
	,substance_abuse_parent TINYINT
	,incarceration_parent TINYINT
	,parental_separation TINYINT
	,domestic_violence_parent TINYINT
	,time_in_care TINYINT
)
GO

CREATE CLUSTERED INDEX i_cover ON #pop (snz_uid, snz_birth_date_proxy, ace_date)
GO

INSERT INTO #pop (snz_uid, snz_birth_date_proxy, ace_date)
SELECT DISTINCT pd.snz_uid
	 , snz_birth_date_proxy
	 , DATEFROMPARTS(YEAR(srp_ref_date), MONTH(snz_birth_date_proxy), DAY(snz_birth_date_proxy)) AS ace_date
FROM [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS pd	
INNER JOIN [IDI_Clean_$(REFRESH)].[data].[snz_res_pop] AS a
ON a.snz_uid = pd.snz_uid
-- years ending at 1st birthday through to 18th birthday
WHERE YEAR(srp_ref_date) - YEAR(pd.snz_birth_date_proxy) BETWEEN 1 AND 18
AND YEAR(srp_ref_date) BETWEEN 2017 AND 2025
GO

-------------------------------------------------------------------------------
-- 1. Abuse - Physical
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_physical

SELECT a.snz_uid
	, 1 as abuse_physical
	, ace_date
INTO #abuse_physical
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_$(REFRESH)] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Physical_Abused'
AND a.abuse_finding_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT a.snz_uid
	, 1 AS abuse_physical
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] AS a
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
	AND a.incident_start_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT c.snz_uid
	, 1 as abuse_physical
	, ace_date
FROM [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
INNER JOIN [IDI_Clean_$(REFRESH)].[security].[concordance] AS c
ON a.snz_msd_uid = c.snz_msd_uid
INNER JOIN #pop AS p 
ON p.snz_uid = c.snz_uid
AND a.needs_created_date <= p.ace_date
WHERE need_type_code = 'PHY146'	--physical abuse
AND a.needs_created_date  BETWEEN p.snz_birth_date_proxy AND p.ace_date

GO

-------------------------------------------------------------------------------
-- 2. Abuse - Sexual
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_sexual

SELECT a.snz_uid
	, 1 as abuse_sexual
	, ace_date
INTO #abuse_sexual
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_$(REFRESH)] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Sexual_Abused'
AND a.abuse_finding_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT a.snz_uid
	, 1 AS abuse_sexual
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE a.victim_flag = 1 AND a.is_SV_flag = 1
AND a.incident_start_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT c.snz_uid
	, 1 as abuse_sexual
	, ace_date
FROM [IDI_Clean_$(REFRESH)].[security].[concordance] c
INNER JOIN [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
ON a.snz_msd_uid = c.snz_msd_uid
INNER JOIN #pop AS p 
ON p.snz_uid = c.snz_uid
AND a.needs_created_date <= p.ace_date
WHERE need_type_code = 'SXA'	--Sexual abuse
AND a.needs_created_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO

-------------------------------------------------------------------------------
-- 3. Abuse - Emotional
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #abuse_emotional

SELECT a.snz_uid
	, 1 as abuse_emotional
	, ace_date
INTO  #abuse_emotional
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_$(REFRESH)] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Emotional_Abused'
	AND a.abuse_finding_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT a.snz_uid
	, 1 as abuse_emotional
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] AS a 
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE victim_flag = 1
	AND codification = 'SN550' -- EMOTIONAL MALTREATMENT OF CHILD
	AND a.incident_start_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT c.snz_uid
	, 1 as abuse_emotional
	, ace_date
FROM [IDI_Clean_$(REFRESH)].[security].[concordance] c
INNER JOIN [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
ON a.snz_msd_uid = c.snz_msd_uid
INNER JOIN #pop AS p 
ON p.snz_uid = c.snz_uid
AND a.needs_created_date <= p.ace_date
WHERE need_type_code = 'EMO275'	--Emotional abuse
	AND a.needs_created_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO
-------------------------------------------------------------------------------
-- 4. Neglect
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #neglect

SELECT a.snz_uid
	, 1 as neglect
	, ace_date
INTO #neglect
FROM [IDI_Community].[chld_assess_investig_abuse].[assess_investig_abuse_$(REFRESH)] AS a
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.abuse_finding_date <= p.ace_date
WHERE a.abuse_finding = 'Neglect'
	AND a.abuse_finding_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT a.snz_uid
	, 1 as neglect
	, ace_date
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] AS a 
INNER JOIN #pop AS p 
ON p.snz_uid = a.snz_uid
AND a.incident_start_date <= p.ace_date
WHERE victim_flag = 1
	AND (TRY_CAST(codification AS INT) BETWEEN 1771 AND 1788 --Neglect or ill-treatment of persons under care
		OR TRY_CAST(codification AS INT) BETWEEN 3711 AND 3719 --Neglect or ill-treatment of persons under care
		OR codification LIKE 'Y06%' -- Neglect and abandonment
		OR codification = 'SN55Z' --NEGLECT AFFECTING CHILD NEC
		OR codification = 'SN570') --NEGLECT OR ABANDONMENT
	AND a.incident_start_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT c.snz_uid
	, 1 as neglect
	, ace_date
FROM [IDI_Clean_$(REFRESH)].[security].[concordance] c
INNER JOIN [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
ON a.snz_msd_uid = c.snz_msd_uid
INNER JOIN #pop AS p 
ON p.snz_uid = c.snz_uid
AND a.needs_created_date <= p.ace_date
WHERE need_type_code = 'NEG145'	--Neglect
	AND a.needs_created_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO

-------------------------------------------------------------------------------
-- 5. Parental Mental Illness
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #mental_illness_parent

SELECT p.snz_uid
    , 1 AS mental_illness_parent
	, ace_date
INTO #mental_illness_parent
FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_mental_illness_$(REFRESH)] AS a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON a.snz_uid = r.snz_associated_uid --parent/caregiver
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid --child
	AND a.event_date BETWEEN r.start_date AND r.end_date -- caregiving relationship at time of event
	AND a.event_date <= p.ace_date
WHERE p.snz_birth_date_proxy < a.event_date --in lifetime
AND a.event_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO

-------------------------------------------------------------------------------
-- 6. Parental Substance Abuse
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #substance_abuse_parent

SELECT p.snz_uid
    , 1 AS substance_abuse_parent
	, ace_date
INTO #substance_abuse_parent
FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_substance_abuse_$(REFRESH)] AS a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON a.snz_uid = r.snz_associated_uid --parent/caregiver
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid --child
	AND a.event_date BETWEEN r.start_date AND r.end_date -- caregiving relationship at time of event
	AND a.event_date <= p.ace_date
WHERE IIF(r.relationship = 'birth_mother',DATEADD(WEEK,-40,p.snz_birth_date_proxy),p.snz_birth_date_proxy) < a.event_date  --in lifetime including prenatal
AND a.event_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL 

--the below are evidence of maternal substance use during pregnancy--

SELECT  c.snz_uid
		, 1 AS substance_abuse_parent
		, ace_date
FROM #pop AS po
INNER JOIN [IDI_Clean_$(REFRESH)].[security].[concordance] AS c
ON c.snz_uid = po.snz_uid
LEFT JOIN [IDI_Community].[dsbl_fasd].[fasd_$(REFRESH)] AS f --FASD (not yet updated with 2025 socrates/202603 primhd or 202511 gateway)
ON f.snz_uid = po.snz_uid

	--the below can be removed when code module is updated
	LEFT JOIN [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
	ON a.snz_msd_uid = c.snz_msd_uid 
	AND need_type_code = 'FAE'--Foetal Alcohol Spectrum Disorder
	LEFT JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[socrates_disability] AS s
	ON s.snz_uid = po.snz_uid AND soc_dis_code = 1106 --FASD
	LEFT JOIN [IDI_Adhoc].[clean_read_MOH_PRIMHD].[primhd_diagnoses_202510] AS p
	ON p.snz_moh_uid = c.snz_moh_uid 
    AND SUBSTRING(p.[clinical_code],1,4) = 'Q860'
    AND p.[clinical_coding_system_id] >= '10'

WHERE po.snz_birth_date_proxy <= po.ace_date --FASD is present at birth
AND (a.snz_msd_uid IS NOT NULL OR s.snz_uid IS NOT NULL OR f.snz_uid IS NOT NULL OR p.snz_moh_uid IS NOT NULL)

UNION ALL

SELECT p.snz_uid
    , 1 AS substance_abuse_parent
	, ace_date
FROM #pop p
INNER JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_event] AS e
ON e.snz_uid = p.snz_uid
INNER JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_diag] AS d 
ON e.moh_evt_event_id_nbr = d.moh_dia_event_id_nbr
WHERE p.snz_birth_date_proxy <= p.ace_date --birth related
AND moh_dia_clinical_sys_code = moh_dia_submitted_system_code
--Clinical codes--
AND SUBSTRING([moh_dia_clinical_code],1,4) IN (
	'P043' -- fetus and newborn affected by maternal use of alcohol
	, 'P044' -- fetus and newborn affected by maternal use of drugs of addiction 
	, 'P961' -- withdrawal symptoms from maternal use of drugs of addiction
)  
GO


-------------------------------------------------------------------------------
-- 7. Parental Inceration
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #incarceration_parent

SELECT p.snz_uid
	, 1 AS incarceration_parent
	, ace_date
INTO #incarceration_parent
FROM [IDI_Clean_$(REFRESH)].[cor_clean].[muster] AS a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON a.snz_uid = r.snz_associated_uid --parent/caregiver
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid --child
	AND a.cor_mus_muster_end_date >= r.start_date 
	AND a.cor_mus_muster_start_date <= r.end_date -- caregiving relationship at time of incarceration
	AND a.cor_mus_muster_start_date <= p.ace_date
	AND p.snz_birth_date_proxy < a.cor_mus_muster_end_date  --in lifetime
	AND a.cor_mus_muster_start_date < p.ace_date
GO

-------------------------------------------------------------------------------
-- 8. Domestic Violence
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #Domestic_violence_parent

SELECT p.snz_uid
	, 1 as Domestic_violence_parent
	, ace_date
INTO #Domestic_violence_parent
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_$(REFRESH)] AS a 
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON a.snz_uid = r.snz_associated_uid --parent/caregiver
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid --child
	AND a.incident_end_date >= r.start_date 
	AND a.incident_start_date <= r.end_date -- caregiving relationship at time of incident
	AND a.incident_start_date <= p.ace_date
	AND a.incident_end_date > p.snz_birth_date_proxy --in lifetime
WHERE is_FV_flag = 1
AND a.incident_start_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT c.snz_uid
	, 1 as Domestic_violence_parent
	, ace_date
FROM [IDI_Clean_$(REFRESH)].[security].[concordance] c
INNER JOIN [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a 
ON a.snz_msd_uid = c.snz_msd_uid
INNER JOIN #pop AS p 
ON p.snz_uid = c.snz_uid
AND a.needs_created_date <= p.ace_date
WHERE need_type_code = 'EFV' --	Exposure to Family Violence
AND a.needs_created_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO

-------------------------------------------------------------------------------
-- 9. Parental Seperation
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #parental_separation

SELECT p.snz_uid
	, 1 as parental_separation
	, ace_date
INTO #parental_separation
FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_separation_$(REFRESH)] AS a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON a.snz_uid = r.snz_associated_uid --parent
	AND r.relationship LIKE '%birth%'
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid --child
	AND a.end_date <= p.ace_date
WHERE a.end_date BETWEEN p.snz_birth_date_proxy AND p.ace_date

UNION ALL

SELECT p.snz_uid
	 , 1 as parental_separation
	, ace_date
FROM  [IDI_Community].[inc_support_paymt].[support_paymt_$(REFRESH)] b
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON b.snz_uid = r.snz_associated_uid
	AND r.relationship LIKE '%birth%'
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid
	AND b.period_end_date > r.start_date 
	AND b.period_start_date < r.end_date -- caregiving relationship at time of benefit receipt
	AND b.period_end_date <= p.ace_date
WHERE b.period_end_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
AND b.[income_source] = 'Sole Parent Support'

UNION ALL

SELECT p.snz_uid
	 , 1 as parental_separation
	, ace_date
FROM [IDI_Clean_$(REFRESH)].[cen_clean].[census_individual_2023] cen
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
	ON cen.snz_uid = r.snz_associated_uid
	AND r.relationship LIKE '%birth%' 
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid
	AND '2023-03-31' <= p.ace_date
	AND '2023-03-31' BETWEEN r.start_date AND r.end_date -- caregiving relationship at time of census
WHERE p.snz_birth_date_proxy < '2023-03-31' --census period
AND cen.cen_ind_family_role_code IN (2,21) --sole parent

UNION ALL 

SELECT p.snz_uid
	 , 1 as parental_separation
	, ace_date
FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_child_parent_$(REFRESH)] r
INNER JOIN #pop AS p 
	ON p.snz_uid = r.snz_uid
	AND r.start_date <= p.ace_date -- relationship began during childhood
WHERE r.relationship LIKE '%step%' -- birth parent has a new partner
GO

-------------------------------------------------------------------------------
-- 10. Experience of care //this is an extended ACE//
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS #time_in_care

SELECT p.snz_uid
    , 1 as time_in_care
	, ace_date
INTO #time_in_care
FROM [IDI_Community].[chld_placement_spell].[placement_spell_$(REFRESH)] plc
INNER JOIN #pop AS p
	ON p.snz_uid = plc.snz_uid
	AND plc.from_date <= p.ace_date
WHERE plc.business_area_type = 'CNP'
AND plc.from_date BETWEEN p.snz_birth_date_proxy AND p.ace_date
GO

-------------------------------------------------------------------------------
-- Index and update
-------------------------------------------------------------------------------

CREATE NONCLUSTERED INDEX i_uid ON #abuse_physical (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #abuse_emotional (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #abuse_sexual (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #neglect (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #mental_illness_parent (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #substance_abuse_parent (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #incarceration_parent (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #parental_separation (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #domestic_violence_parent (snz_uid, ace_date)
CREATE NONCLUSTERED INDEX i_uid ON #time_in_care (snz_uid, ace_date)
GO

UPDATE p
SET abuse_physical = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #abuse_physical AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET abuse_emotional = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #abuse_emotional AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET abuse_sexual = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #abuse_sexual AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET neglect = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #neglect AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET mental_illness_parent = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #mental_illness_parent AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET substance_abuse_parent = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #substance_abuse_parent AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET incarceration_parent = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #incarceration_parent AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET parental_separation = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #parental_separation AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET domestic_violence_parent = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #domestic_violence_parent AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

UPDATE p
SET time_in_care = 1
FROM #pop AS p
WHERE EXISTS (SELECT 1 FROM #time_in_care AS s WHERE p.snz_uid = s.snz_uid AND p.ace_date = s.ace_date)
GO

-------------------------------------------------------------------------------
-- Final table 
-------------------------------------------------------------------------------

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_conventional_ACE_scores_$(REFRESH)]
GO

SELECT p.snz_uid
	, p.ace_date
	, snz_birth_date_proxy
	--Abuse
	, COALESCE(abuse_physical , 0) AS abuse_physical
	, COALESCE(abuse_emotional , 0) AS abuse_emotional
	, COALESCE(abuse_sexual, 0) AS abuse_sexual
	--Neglect
	, COALESCE(neglect, 0) AS neglect
	--Parental 
	, COALESCE(mental_illness_parent, 0) AS mental_illness_parent
	, COALESCE(substance_abuse_parent, 0) AS substance_abuse_parent
	, COALESCE(incarceration_parent, 0) AS incarceration_parent
	, COALESCE(parental_separation, 0) AS parental_separation
	, COALESCE(domestic_violence_parent, 0) AS domestic_violence_parent
	, COALESCE(time_in_care, 0) AS time_in_care
	--score calculation
	,COALESCE(abuse_physical, 0)
		+ COALESCE(abuse_emotional, 0)
		+ COALESCE(abuse_sexual, 0)
		+ COALESCE(neglect, 0)
		+ COALESCE(mental_illness_parent, 0)
		+ COALESCE(substance_abuse_parent, 0)
		+ COALESCE(incarceration_parent, 0)
		+ COALESCE(parental_separation, 0)
		+ COALESCE(domestic_violence_parent, 0)
		+ COALESCE(time_in_care, 0)
	AS ACE_score
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_conventional_ACE_scores_$(REFRESH)]
FROM #pop AS p

GO

-- Compress and index
-- original / naive
-- ALTER TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_generalised_ACE_scores_$(REFRESH)] REBUILD PARTITION = ALL WITH(DATA_COMPRESSION = PAGE)
-- procedure / faster
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_generalised_ACE_scores_$(REFRESH)]'

CREATE NONCLUSTERED INDEX ace_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_conventional_ACE_scores_$(REFRESH)]  (snz_uid)
GO

