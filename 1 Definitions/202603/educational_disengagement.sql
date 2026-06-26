/**************************************************************************************************
Title: Educational disengagement
Author: Charlotte Rose
Reviewer: 

Description:
This definition combines a number of measures pointing to increased disengagement with education in children.

Each child is observed once every year they have an event

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[data].[personal_detail]
- [IDI_Clean_$(REFRESH)].[data].[snz_res_pop]
- [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions]
- [IDI_Community].[edu_sch_att_year].[sch_att_year_$(REFRESH)]
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_transient_students_$(REFRESH)] -- (transient_students_$(REFRESH).sql)
- [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511]
- [IDI_Metadata_$(REFRESH)].[moe_school].[se_service_category_code]
- [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code]


Notes:

-- intervetions are only reliable after 2007, so this definition begins in 2008. The earilest 'lifetime' data birth cohort will be born in 2003 - assuming they start school when they are 5 in 2008.

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
  Residence year range = 2008 to 2025
 
Issues:

Future work could include source information i.e. If person A had 3 stand down in 2017 and 3 referrals to the attendance service, they will have 1 disciplinary_actions row and 1 attendance_service row for the disenegage year ending 2017-12-31.

This method would allow the data to be filtered to types of disengagement.
 
History (reverse order):
2026-04-22 CR added behaiour related learning supports
2026-03-09 CR v1
**************************************************************************************************/

 --:SETVAR PROJECT_DB "SIA_Sandpit"
 --:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
 --:SETVAR REFRESH "202603"

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_education_disengagement_$(REFRESH)]

CREATE TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_education_disengagement_$(REFRESH)] (
	snz_uid INT
	, disengage_date DATE
	, SSEE INT
	, AltEd INT
	, AttServ INT
	, ChronAbs INT
	, Transience INT
	, AdditionalNeeds INT
	, BehavSupprt INT
)

-- Establish compression on empty table
ALTER TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_education_disengagement_$(REFRESH)] REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)

-------------------------------------------------------------------------------
-- Resident and under 18
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS #pop

SELECT DISTINCT pd.snz_uid
	 , snz_birth_date_proxy
	 , DATEFROMPARTS(YEAR(srp_ref_date), 12, 31) AS disengage_date
INTO #pop
FROM [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS pd	
INNER JOIN [IDI_Clean_$(REFRESH)].[data].[snz_res_pop] AS a
ON a.snz_uid = pd.snz_uid
WHERE FLOOR(DATEDIFF(MONTH, pd.snz_birth_date_proxy, DATEFROMPARTS(YEAR(srp_ref_date), 12, 31)) / 12) BETWEEN 0 AND 17
AND YEAR(srp_ref_date) BETWEEN 2008 AND 2025

CREATE NONCLUSTERED INDEX snz_uid ON #pop (snz_uid)
GO

-------------------------------------------------------------------------------
--1. Disciplinary actions
-------------------------------------------------------------------------------

INSERT INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_education_disengagement_$(REFRESH)]

SELECT DISTINCT a.snz_uid
   , disengage_date
   , 1 AS SSEE
   , NULL AS AltEd
   , NULL AS AttServ
   , NULL AS ChronAbs
   , NULL AS Transience
   , NULL AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] AS a
INNER JOIN #pop AS p  
ON a.snz_uid = p.snz_uid
AND a.moe_inv_start_date <= p.disengage_date
WHERE [moe_inv_intrvtn_code] IN (7 -- Suspension (this includes expulsions and exclusions)
								,8) --Stand down
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.moe_inv_start_date) / 12) <= 17

UNION

-------------------------------------------------------------------------------
--2. Alternative education
-------------------------------------------------------------------------------

SELECT DISTINCT a.snz_uid
   , disengage_date
   , NULL AS SSEE
   , 1 AS AltEd
   , NULL AS AttServ
   , NULL AS ChronAbs
   , NULL AS Transience
   , NULL AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] AS a
INNER JOIN #pop AS p  
ON a.snz_uid = p.snz_uid
AND a.moe_inv_start_date <= p.disengage_date
WHERE [moe_inv_intrvtn_code] = 6 -- Alternative Education
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.moe_inv_start_date) / 12) <= 17

UNION
-------------------------------------------------------------------------------
--3. Attendance service
-------------------------------------------------------------------------------

SELECT DISTINCT a.snz_uid
	, disengage_date
	, NULL AS SSEE
	, NULL AS AltEd
	, 1 AS AttServ
	, NULL AS ChronAbs
	, NULL AS Transience
	, NULL AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] AS a
INNER JOIN #pop AS p  
	ON a.snz_uid = p.snz_uid
	AND a.moe_inv_start_date <= p.disengage_date
WHERE a.moe_inv_intrvtn_code IN (9 -- Non Enrolment Truancy Service
								,32) -- Truancy (Unjustified Absence)
AND FLOOR(DATEDIFF(MONTH, p.snz_birth_date_proxy, a.moe_inv_start_date) / 12) <= 17

UNION
-------------------------------------------------------------------------------
--4. Chronic absence
-------------------------------------------------------------------------------

SELECT DISTINCT a.snz_uid
	, disengage_date
	, NULL AS SSEE
	, NULL AS AltEd
	, NULL AS AttServ
	, 1 AS ChronAbs
	, NULL AS Transience
	, NULL AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_Community].[edu_sch_att_term].[sch_att_term_$(REFRESH)] AS a
INNER JOIN #pop AS p  
ON a.snz_uid = p.snz_uid
AND a.year = YEAR(p.disengage_date)
AND a.attendance = 'Chronic Absence' -- Absent for over 15 days in any term in the year

UNION
-------------------------------------------------------------------------------
--5. Transience
-------------------------------------------------------------------------------

SELECT DISTINCT p.snz_uid
	, disengage_date
	, NULL AS SSEE
	, NULL AS AltEd
	, NULL AS AttServ
	, NULL AS ChronAbs
	, 1 AS Transience
	, NULL AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_transient_students_$(REFRESH)] AS a
INNER JOIN #pop AS p  
ON a.snz_uid = p.snz_uid
AND YEAR(a.date_started) = YEAR(p.disengage_date)
GROUP BY p.snz_uid, disengage_date
HAVING COUNT(*) >= 2 --two or more non-structural school moves

UNION
-------------------------------------------------------------------------------
--6. OT Gateway Identified educational needs
-------------------------------------------------------------------------------

SELECT DISTINCT p.snz_uid
	, disengage_date
	, NULL AS SSEE
	, NULL AS AltEd
	, NULL AS AttServ
	, NULL AS ChronAbs
	, NULL AS Transience
	, 1 AS AdditionalNeeds
   , NULL AS BehavSupprt
FROM [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] a
INNER JOIN [IDI_Clean_$(REFRESH)].[security].[concordance] c
ON c.snz_msd_uid = a.snz_msd_uid
INNER JOIN #pop AS p  
ON c.snz_uid = p.snz_uid
AND YEAR(a.needs_created_date) = YEAR(p.disengage_date)
WHERE need_category_code IN ('ATCO'--	SCH Attendance and Conduct
							, 'BHSS'--	SCH Behaviour/Social Skills
							)

UNION
-------------------------------------------------------------------------------
--7. Learning supports for behaviour challenges
-------------------------------------------------------------------------------

SELECT DISTINCT p.snz_uid
	, disengage_date
	, NULL AS SSEE
	, NULL AS AltEd
	, NULL AS AttServ
	, NULL AS ChronAbs
	, NULL AS Transience
	, NULL AS AdditionalNeeds
	, 1 AS BehavSupprt
FROM [IDI_Clean_$(REFRESH)].[moe_clean].[student_interventions] AS i
LEFT JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[se_service_category_code] AS se
ON se.[SEServiceCategoryId] = i.[moe_inv_se_service_category_code]
INNER JOIN [IDI_Metadata_$(REFRESH)].[moe_school].[intervention_type_code] AS t 
ON t.InterventionID = i.moe_inv_intrvtn_code
INNER JOIN #pop AS p  
ON i.snz_uid = p.snz_uid
AND YEAR(i.moe_inv_start_date) = YEAR(p.disengage_date)
WHERE [moe_inv_intrvtn_code] IN (37) -- Interim Response Fund (fund to help schools support students with disruptive behaviour or critical behaviour cases)
OR [moe_inv_se_service_category_code] IN (2,10,17) -- Special education: behaviour service,intensive wrap around service (for children with highly complex learning and behaviour challenges) & Assessments for Youth Offending


CREATE NONCLUSTERED INDEX s_uid ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_education_disengagement_$(REFRESH)]  (snz_uid)
GO

--Tidy up--

DROP TABLE IF EXISTS #pop
