/***************************************************************************************************************************
<div data-theme-toc="true"></div>

# Module Output
>**SQL:**
[IDI_Community].[emp_eet_flexible].[eet_flexible_YYYYMM]
[IDI_Community].[emp_ett_neet].[eet_neet_YYYYMM]
>**SAS:** 
libname cm_ot OBDC dsn=idi_community_srvprd schema=cm_read_EET_FLEXIBLE_YYYYMM; run; 
proc print data = cm_read_EET_FLEXIBLE_YYYYMM; run;
>**How to access a code module in the Data Lab**: [Read here](https://idcommons.discourse.group/t/how-to-access-a-code-module-in-the-data-lab/658)

# EET and NEET spells

## Purpose 
This module provides common resources and support to identify spells when people in New Zealand are:

* In employment, education, or training (EET), or
* Not in employment, education, or training (NEET) 

The module provides two output tables. 

The first output table, [EET-NEET], is intended to support the creation of EET and NEET rates. The business rule choices match the settings used to define NEET in the Household Labour Force Survey (HLFS), as best as able. The community of interest feels this is a generally safe and acceptable methodology, suitable for the average user.

The second output table, [EET flexible], provides a flexible output with standard components researchers can use to construct their own custom EET and NEET measures. The documentation for this table will include a discussion of the common business rule choices faced when creating an EET or NEET measure, and some worked examples of live use-cases being used for different use-cases covering policy analysis, monitoring, or intervention targeting. The development team feels this more flexible approach is suitable for advanced users in need of more customisation than the [EET-NEET] table allows.

The development team includes representatives from MBIE, MSD, MoE, SIA, OT, TPK, and Stats NZ and reflects the consensus view of this group for the use-cases described above. It is our hope that this module acts as a forum for ongoing collaboration between these agencies and others across the data system to share, test, and document methodologies on live use-cases as they arise. We expect this collaboration to incrementally improve the outputs and documentation as use-case needs are tested against currently known best practices.

## Value of measuring NEET
Young people who experience prolonged periods where they are not in either employment, education, or training (NEET) are more likely to experience poor outcomes, potentially leading to long-term disadvantage in the labour market. Knowing the number of young people who are NEET is useful for design of initiatives targeted at youth who may not be meeting their full potential. This may include services to help young people transition from school into work or further education.

Official NEET rates are created using a sample survey. Having an alternative approach for identifying NEET in the IDI will allow for more targeted analysis and identification of small and intersectional groups which cannot be accurately measured through a sample survey and may have higher needs, such as specific age groups, school leavers, or ethnic groups where more culturally appropriate interventions may be required.

## What NEET does and doesn't measure
NEET measures the absence of being involved in employment or education, both of which add value both to society and the individual. NEET does not measure specific needs of individuals or whether there are barriers present which restrict individuals progressing. We cannot assume that all young people who are NEET have the same level of need.

The HLFS working-age population automatically excludes those who aren't usually resident in New Zealand or institutionalised (e.g. in prison or long-term care facilities). However, the HLFS NEET definition will include youth who are in the working-age population but not working or in education because of their specific circumstances (e.g. those who are unable to work due to illness or injury, are caregiving, or other circumstances which may be at play).

NEET spells can include people who are doing short training courses through MSD, a contracted ACC provider, or a tertiary education provider.

## Common pitfalls in interpretation of NEET
It is important to interpret NEET with care. NEET measures the absence of activity but does not directly measure the reasons for that absence. When using a NEET measure it is important to have additional population context, for example, are there a lot of young parents? Have people not gained the school qualifications needed to lead into tertiary education or employment? Are there cultural or generational effects at play? NEET is a starting point, but does not and cannot tell the whole story.

International definitions tend to measure NEET in 15-24 year-olds. In a New Zealand context however, including 15-year-olds in the numerator and denominator may lower the rate making it less reflective of the 'true' NEET rate, as children legally must be at school until their 16th birthday. This is something to consider when constructing rates.

When there are significant changes going on in population numbers by year of age and over time, this can affect the rates for 15- to 19-year-olds. This is because the NEET rate at each year of age from 15 to 19 is quite different. If the age composition of this group changes, so will the overall NEET rate. Excluding 15-year-olds mitigates against this. 

## Key Concepts
### EET-NEET

This module provides EET and pre-constructed NEET spells using rules based on HLFS populations and NEET identification.

The total population is limited to those who are:

The total population is limited to those who are:
* 15-24 years, 
* on shore, and
* not incarcerated. 

This compares with the HLFS youth working-age population of, 'non-institutionalised, usually resident New Zealand population aged 15-24 years'.

In this module, an EET spell can be defined as those within this population who have been identified to be:
* In employment and/or
* In education (school, tertiary, or industry training)

NEET spells are constructed for those within the total population who have not been identified as either in employment or education for a given period.

This compares with the HLFS NEET identification of youth who are not employed (unemployed or not in the labour force) and who specify that they were not in education or training (not still in secondary school, working toward a qualification, or doing any study or training the week prior to being interviewed). 
	
### EET (flexible)

This module can be used to construct spells where an individual is NEET, based on which criteria the researcher wishes to apply, such as:
* Filtering for specific age groups
* Including incapacitation spells as non-NEET, which may be useful when identifying NEET populations which may be amenable to support and intervention

In this module, the following spells can be identified for people between 15 and 64 years of age:
* In employment
* In education (school, tertiary, or industry training)
* Overseas
* In prison or on remand
* Deemed unfit for work by either MSD or ACC as per a medical certificate ('incapacitated')

Any or all of these spells can be used to exclude someone from being identified in a custom NEET population, identifying them as non-NEET/EET+.
	
## Comparison against other sources
The results of this module have been compared to the status of those aged 15 to 24 in the HLFS sample, using the IDI HLFS dataset and the EET-NEET table.

For testing, the HLFS interview period must fall wholly inside an EET or NEET spell (to avoid status changes within the HLFS week).

The status (EET or NEET) found in the module has been compared to the status as reported in the HLFS.
* The match rate for EET status from 2015 to 2023 is, on average 97%
* The match rate for NEET status from 2015 to 2023 is, on average 68%

It is accepted that there is some discrepancy in NEET status matching due to:
* The code module (both EET-NEET and EET-Flexible) not including the majority of self-employed individuals (14% on average of mismatched group) or any unpaid family workers as EET
* The code module (both EET-NEET and EET-Flexible) not accounting for the summer break
* The code module (both EET-NEET and EET-Flexible) not including tertiary education other than type D courses or ITO >40 credits
* HLFS exclusion of people with unknown study statuses from NEET
* The EET_NEET code module not accounting for those off work on ACC
* Potential linkage and response errors

## References & Contacts
MoE (2019): [Not just about NEETs: A rapid review of evidence on what works for youth at risk of limited employment | Education Counts](https://www.educationcounts.govt.nz/publications/80898/not-just-about-neets)

MBIE (2013): [Not in employment, education or training: the long-term NEET spells of young people in New Zealand](https://thehub.sia.govt.nz/assets/documents/NEET%20spells%20of%20young%20people%20in%20New%20Zealand.pdf) 

## Code module technical information
In the flexible table, each non-NEET spell is defined, with date constrains based on age and data availability are stacked to make a combined table of all spells. The final table includes spell types and an entity. This is an MOE entity, which would be required if outputting non-NEET spells, or a dummy entity.

Overlapping spells of the same type, have been combined into a single spell, e.g. overlapping MOE spells where an individual was enrolled with two providers (school and teen parent unit, for example)

In the EET-NEET table all EET spells which overlap or are adjacent have been combined

## Development team

|Role			            |Agency											 |Person			 |
|---------------------------|------------------------------------------------|-------------------|
|Code development           | Social Investment Agency						 |Charlotte Rose	 |
|SME advice 				| Stats NZ (HLFS)  								 |Alexandra Ferguson |
|							| Ministry of Education							 |Dee Earle			 |
|							| Social Investment Agency						 |Dion Gamperle		 |
|							| Ministry of Social Development				 |John Gibbs		 |
|							| Oranga Tamariki								 |Eyal Apatov		 |
|							| Ministry of Business, Innovation and Emplyoment|Lloyd Pledger		 |
|							| Te Puni Kokiri								 |Angus Prain		 |
|Peer review (code)			| Social Investment Agency						 |Dan Young			 |
|							| Nicholson Consulting							 |Tori Van Loenhout  |

## Module Business Rules
### Dates:
* There is a hard start date of an individuals' 15th birthday as this the age from which EET and NEET are traditionally measured
* There is a hard end date of an individuals' 25th birthday in the EET_NEET table as HLFS measure NEET between the ages of 15 and 24
* There is a hard end date of an individuals' 65th birthday (retirement age) in the flexible table
* A hard end date for open spells is the maximum date for the data, i.e in the 202503 refresh, the end date is 2023-12-31


### Spell definitions:
#### Used in both tables
* Employment spells use employee start and end dates where they exist, otherwise are proxied from the first day of the EMS return month, to the last day of the EMS return month.
* Education is limited to schools (including Te Kura), type D tertiary courses, and industry training courses of 40 credits or more. NOTE: private school data may be incomplete
* Incarceration includes spells in both prison and on remand
	
#### Flexible table only
* Incapacitation includes spells receiving weekly compensation from ACC or spells receiving supported living payments (Health Condition, Injury or Disability), both of which mean someone is unable to work due to illness, injury or disability. People in these groups may have overlapping spells (i.e. overseas, prison or education).
* Overseas includes those out of the country as per the DOL table, and uses exit and entry dates to calculate spells

## Open Issues/Comments
1.	MOE tertiary education data is updated annually in the June refresh with an end date of 31st of December the previous year (e.g. in the June 2024 refresh, an end date of 2023-12-31). This means the end date when calculating NEET spells need be calculated only to that date, otherwise people who are in tertiary education will be recorded as NEET.
2.	MOE entities are required for outputting EET spells involving education.
3.	Employment entities are not required when outputting EET, as we are measuring the status of the individual rather than an aspect of a business.
4.	Entities are not required when outputting NEET, as we are measuring the absence of the activity.

## Parameters
The following parameters should be supplied to this module to run it in the database:

1.	{targetdb}: The SQL database on which the spell datasets are to be created.
2.	{idicleanversion}: The IDI Clean version that the spell datasets need to be based on.
3.	{targetschema}: The project schema under the target database into which the spell datasets are to be created.
4.	{projprefix}: A (short) prefix that enables you to identify the spell dataset easily in the schema, and prevent overwriting any existing datasets that have the same name.

DECLARE variables do not need to be changed

5.	@refresh: Current refresh YYYYMM(to calculate max dates)
6.	@mindate: The minimum complete date across all datasets
7.	@maxdate: The maximum complete date across all datasets

[IDI_Clean_YYYYMM].[data].[person_overseas_spell]
## Dependencies

* [IDI_Clean_YYYYMM].[data].[personal_detail]
* [IDI_Clean_YYYYMM].[cor_clean].[ra_ofndr_major_mgmt_period_a]
* [IDI_Clean_YYYYMM].[moe_clean].[student_enrol]
* [IDI_Clean_YYYYMM].[moe_clean].[enrolment]
* [IDI_Clean_YYYYMM].[moe_clean].[tec_it_learner]
* [IDI_Clean_YYYYMM].[acc_clean].[claims]
* [IDI_Clean_YYYYMM].[ir_clean].[ems]
* [IDI_Community].[cm_read_INCOME_T1_INC_SUPPORT_PAYMT].[income_t1_inc_support_paymt_YYYYMM]

## Outputs
* [IDI_Community].[cm_read_EET_NEET].[eet_neet_YYYYMM]
* [IDI_Community].[cm_read_EET_FLEXIBLE].[eet_flexible_YYYYMM]

## Variable Descriptions
### EET_NEET

|Column name			|Description|
|-----------------------|--------------------------------------------------------------------------------------------------------|		  
|snz_uid				|The unique STATSNZ person identifier for the the individual|
|dob					|Date of birth (proxy) of the individual					|
|spell_type				|EET or NEET												|
|start_date				|Start date of spell 										|
|end_date				|End date of spell											|
|MOE					|Flag if an activity during the spell was education			|
|IRD					|Flag if an activity during the spell was employment 		|
|entity					|Provider code for education provider (non MOE = dummy code)|

### EET-flexible

|Column name			|Description|
|-----------------------|--------------------------------------------------------------------------------------------------------|		  
|snz_uid				|The unique STATSNZ person identifier for the the individual|
|dob					|Date of birth (proxy) of the individual					|
|start_date				|Start date of non-NEET activity							|
|end_date				|End date of non-NEET activity								|
|spell_type				|Type of activity, by dataset used							|
|entity					|Provider code for education provider (non MOE = dummy code)|

## Module Version & Change History

|Date               |Version 		|Comments |                  
|-------------------|---------------|-----------------------------------------------------------------|
|2025-03-26		    |Initial		|Charlotte Rose - Version based on specifications from Commissioning document.|
|2025-05-05			|Code logic QA	|Dan Young 															  		  |	
|2025-05-15			|Post QA update	|Charlotte Rose															      |	

# Code

***************************************************************************************************************************/
/* Set parameters turn on SQLCMD to run*/

/*
-- have been find & replaced to run in pipeline
:setvar targetdb "SIA_Sandpit"
:setvar targetschema "DL-MAA2023-46"
:setvar idicleanversion "IDI_Clean_202506"
:setvar refreshversion "202506"
:setvar projprefix "defn"
*/

/*<ft_code_start_eet_flexible>*/

/*<ft_dependency_income_t1_inc_support_paymt>*/

/*
-- have been find & replaced to run in pipeline
:setvar targetdb "SIA_Sandpit"
DECLARE @refresh INT
	,@mindate DATE
	,@maxdate  DATE;
*/

/*SET @refresh = RIGHT('IDI_Clean_202506',6)*/
/*
-- have been find & replaced to run in pipeline
:setvar targetdb "SIA_Sandpit"
SET @refresh = 202506
*/

/*earliest complete date available for MOE*/
/*
-- have been find & replaced to run in pipeline
:setvar targetdb "SIA_Sandpit"
SET @mindate = '2009-01-01' 
*/

/*Currently, the MOE tertiary data only updated in June refresh to EO previous year*/
/*
-- have been find & replaced to run in pipeline -- = '2024-12-31' for 202506 refresh
:setvar targetdb "SIA_Sandpit"
SET	@maxdate = IIF(RIGHT(@refresh,2) = '03', DATEFROMPARTS(LEFT(@refresh,4)-2,12,31), DATEFROMPARTS(LEFT(@refresh,4)-1,12,31))
*/

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_202506];
DROP TABLE IF EXISTS #pop;
DROP TABLE IF EXISTS #EET;
DROP TABLE IF EXISTS #EET_linked;

/*input population*/

SELECT snz_uid
    ,snz_birth_date_proxy as dob
	,IIF(DATEADD(YEAR,15,snz_birth_date_proxy)>'2009-01-01',DATEADD(YEAR,15,snz_birth_date_proxy),'2009-01-01') AS [inclusion_start]
	,IIF(DATEADD(YEAR,65,snz_birth_date_proxy)>'2024-12-31','2024-12-31',DATEADD(YEAR,65,snz_birth_date_proxy)) AS	[inclusion_end]
	INTO #pop
FROM IDI_Clean_202506.[data].[personal_detail]
WHERE DATEDIFF(MONTH,snz_birth_date_proxy,'2024-12-31' ) >= 15*12
	AND DATEDIFF(MONTH,snz_birth_date_proxy,'2009-01-01' ) <= 64*12
	AND snz_spine_ind = 1
	AND snz_person_ind = 1
	;

/* overseas spells */
WITH EET as (
 SELECT  a.snz_uid
	, p.dob
    , CAST(a.pos_applied_date AS DATE)  AS start_date
	/*giving nulls (current spells) a max end date*/
    , COALESCE(CAST(a.pos_ceased_date AS DATE), p.inclusion_end) AS end_date
    , 'DOL' AS spell_type
	/*Give a random entity number*/
	, CAST(ABS(CHECKSUM(NEWID())) % 10000 - 1000 as INT) + 1000 AS entity
	,p.inclusion_start
	,p.inclusion_end
FROM IDI_Clean_202506.[data].[person_overseas_spell] a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
WHERE p.inclusion_start <= COALESCE(CAST(a.pos_ceased_date AS DATE), p.inclusion_end)
	AND CAST(a.pos_applied_date AS DATE) <= p.inclusion_end 
	AND COALESCE(CAST(a.pos_ceased_date AS DATE), p.inclusion_end) >= CAST(a.pos_applied_date AS DATE) 

UNION ALL

/* school enrolments */

SELECT a.snz_uid
	, p.dob
    , a.moe_esi_start_date AS start_date 
    , COALESCE(a.moe_esi_end_date, p.inclusion_end) AS end_date
	, 'MOE' AS spell_type
	, MAX(a.moe_esi_provider_code) AS entity
	,p.inclusion_start
	,p.inclusion_end
FROM IDI_Clean_202506.[moe_clean].[student_enrol] a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
WHERE COALESCE(a.moe_esi_end_date, p.inclusion_end) >= p.inclusion_start
	/* excluding one day enrolments */
	AND (a.moe_esi_end_date IS NULL
			OR DATEDIFF(DAY, a.moe_esi_start_date,a. moe_esi_end_date) > 1)
	AND a.moe_esi_start_date <= p.inclusion_end
	AND COALESCE(a.moe_esi_end_date, p.inclusion_end) >= a.moe_esi_start_date
GROUP BY a.snz_uid
    ,p.inclusion_start
	,p.inclusion_end
	,a.moe_esi_start_date
	,COALESCE(a.moe_esi_end_date, p.inclusion_end)
	,p.dob


UNION ALL

/* tertiary enrolments */

SELECT enr.snz_uid
	, p.dob
    , enr.moe_enr_prog_start_date AS start_date
    , CASE WHEN crs.moe_crs_withdrawal_date IS NOT NULL AND crs.moe_crs_withdrawal_date < enr.moe_enr_prog_end_date THEN crs.moe_crs_withdrawal_date
		   ELSE enr.moe_enr_prog_end_date END AS end_date
    , 'MOE' AS spell_type
	, MAX(moe_enr_provider_code) AS entity
	,p.inclusion_start
	,p.inclusion_end
FROM IDI_Clean_202506.[moe_clean].[enrolment] enr 
LEFT JOIN IDI_Clean_202506.[moe_clean].[course] crs
ON enr.snz_uid = crs.snz_uid
AND enr.moe_enr_snz_unique_nbr = crs.moe_crs_snz_unique_nbr
AND enr.moe_enr_prog_start_date = crs.moe_crs_start_date
INNER JOIN #pop p on enr.snz_uid = p.snz_uid
/* Formal education of more than 1 week duration */
WHERE enr.moe_enr_qual_type_code = 'D'
	AND CASE WHEN crs.moe_crs_withdrawal_date IS NOT NULL AND crs.moe_crs_withdrawal_date < enr.moe_enr_prog_end_date THEN crs.moe_crs_withdrawal_date
		   ELSE enr.moe_enr_prog_end_date END >= p.inclusion_start
	AND enr.moe_enr_prog_start_date <= p.inclusion_end
	AND CASE WHEN crs.moe_crs_withdrawal_date IS NOT NULL AND crs.moe_crs_withdrawal_date < enr.moe_enr_prog_end_date THEN crs.moe_crs_withdrawal_date
		   ELSE enr.moe_enr_prog_end_date END >= enr.moe_enr_prog_start_date
GROUP BY enr.snz_uid
	, p.dob
	, p.inclusion_start
	, p.inclusion_end
	, enr.moe_enr_prog_start_date
	,CASE WHEN crs.moe_crs_withdrawal_date IS NOT NULL AND crs.moe_crs_withdrawal_date < enr.moe_enr_prog_end_date THEN crs.moe_crs_withdrawal_date
	 ELSE enr.moe_enr_prog_end_date END

UNION ALL 

/*Enrolment in industry training*/

SELECT b.[snz_uid]
	, p.dob
    , b.start_date AS start_date
    , COALESCE(b.end_date, end_date_proxy) AS end_date
	, 'MOE' AS spell_type
	, MAX(b.moe_itl_ito_edumis_id_code) AS entity
	, p.inclusion_start
	, p.inclusion_end
FROM(
    SELECT [snz_uid]
        , moe_itl_start_date AS start_date
		/*estimated end date based on course duration*/
		, DATEADD(MONTH,moe_itl_duration_months_nbr,moe_itl_start_date) as end_date_proxy
        , [moe_itl_end_date] AS end_date
		, moe_itl_ito_edumis_id_code
    FROM IDI_Clean_202506.[moe_clean].[tec_it_learner]
	/*programmes of study that involve at least 3 months FTE*/
    WHERE [moe_credit_value_nbr] >= 40 
		)b
INNER JOIN #pop p on b.snz_uid = p.snz_uid
WHERE IIF(COALESCE(b.end_date, b.end_date_proxy) > p.inclusion_end,p.inclusion_end,COALESCE(b.end_date, b.end_date_proxy)) >= p.inclusion_start
	AND b.start_date <= p.inclusion_end
	AND COALESCE(b.end_date, b.end_date_proxy) >= b.start_date 
GROUP BY b.snz_uid
	,p.dob
	,p.inclusion_start
	,p.inclusion_end
	,b.start_date
	,COALESCE(b.end_date, b.end_date_proxy)

UNION ALL

/* employment*/ 

SELECT a.snz_uid
	, dob
	, a.start_date AS start_date 
	, IIF(a.ir_ems_return_period_date > p.inclusion_end, p.inclusion_end,a.ir_ems_return_period_date ) AS end_date
	, 'IRD' as spell_type
	, CAST(ABS(CHECKSUM(NEWID())) % 10000 - 1000 as INT) + 1000 AS entity
	, p.inclusion_start
	, p.inclusion_end
/*creating a 'spell' using either employee start date, or month of the return period*/
FROM (SELECT *
		,CASE WHEN ir_ems_employee_start_date IS NOT NULL
			AND ir_ems_employee_start_date < ir_ems_return_period_date
			AND DATEDIFF(day,ir_ems_employee_start_date,ir_ems_return_period_date) < 60 
			THEN ir_ems_employee_start_date  
		ELSE DATEFROMPARTS(YEAR(ir_ems_return_period_date),MONTH(ir_ems_return_period_date),1)
		END AS [start_date]
		FROM IDI_Clean_202506.[ir_clean].[ird_ems]) a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
WHERE a.ir_ems_income_source_code in ('W&S','WHP','PPL') 
	AND a.ir_ems_return_period_date >= p.inclusion_start
	AND a.start_date <= p.inclusion_end
	AND IIF(a.ir_ems_return_period_date > p.inclusion_end, p.inclusion_end,a.ir_ems_return_period_date ) >= a.start_date


UNION ALL

/* in care of corrections - this uses muster table only
This will updated when the corrections spells code module is published*/

SELECT a.snz_uid
	, p.dob
    , a.cor_mus_muster_start_date
    , COALESCE(a.cor_mus_actual_release_date, a.cor_mus_muster_end_date, p.inclusion_end) AS end_date
    , 'COR' AS spell_type
	, CAST(ABS(CHECKSUM(NEWID())) % 10000 - 1000 as INT) + 1000 AS entity
	, p.inclusion_start
	, p.inclusion_end
FROM IDI_Clean_202506.[cor_clean].[muster] AS a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
WHERE (a.cor_mus_muster_start_date < a.cor_mus_muster_end_date OR a.cor_mus_muster_end_date IS NULL)
	AND COALESCE(a.cor_mus_actual_release_date, a.cor_mus_muster_end_date, p.inclusion_end ) >= p.inclusion_start
	AND a.cor_mus_muster_start_date <= p.inclusion_end
	AND COALESCE(a.cor_mus_actual_release_date, a.cor_mus_muster_end_date, p.inclusion_end) >= a.cor_mus_muster_start_date
	

UNION ALL

/* Off work on ACC */

SELECT a.[snz_uid]
	, p.dob
    , a.acc_cla_first_wc_payment_date AS start_date
    , COALESCE(a.acc_cla_last_wc_payment_date, p.inclusion_end) AS end_date
    , 'ACC' AS spell_type
	, CAST(ABS(CHECKSUM(NEWID())) % 10000 - 1000 as INT) + 1000 AS entity
	, p.inclusion_start
	, p.inclusion_end
FROM IDI_Clean_202506.[acc_clean].[claims] a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
WHERE a.acc_cla_first_wc_payment_date IS NOT NULL
	AND a.acc_cla_last_wc_payment_date >= p.inclusion_start
	AND a.acc_cla_last_wc_payment_date <= p.inclusion_end


UNION ALL

/*Incapacitatied as per MSD benefit receipt*/

SELECT i.[snz_uid]
	, p.dob
    , i.period_start_date AS start_date
    , COALESCE(i.period_end_date, p.inclusion_end) AS end_date
    , 'MSD' AS spell_type
	, CAST(ABS(CHECKSUM(NEWID())) % 10000 - 1000 as INT) + 1000 AS entity
	, p.inclusion_start
	, p.inclusion_end
FROM [IDI_Community].[inc_support_paymt].[support_paymt_202506] i  
INNER JOIN #pop p on i.snz_uid = p.snz_uid
WHERE i.income_source_type = 'Main benefit'
AND i.income_source IN ('Supported Living Payment Health Condition & Disability','Supported Living Payment')
AND COALESCE(i.period_end_date,p.inclusion_end ) >= p.inclusion_start
AND i.period_start_date <= p.inclusion_end
)

/* Trimming table to make sure min date is adhered to*/

SELECT a.snz_uid
	, a.dob
	, IIF(a.start_date < a.inclusion_start,a.inclusion_start,a.start_date) as start_date
	, IIF(a.end_date > a.inclusion_end,a.inclusion_end,a.end_date) as end_date
	, a.spell_type
	, MAX(a.entity) as entity
INTO #EET
FROM EET a
GROUP BY a.snz_uid
	, a.dob
	, IIF(a.start_date < a.inclusion_start,a.inclusion_start,a.start_date)
	, IIF(a.end_date > a.inclusion_end,a.inclusion_end,a.end_date)
	, a.spell_type;

CREATE NONCLUSTERED INDEX i_uid ON #EET (snz_uid)
GO
---------------------------------------------------------------------
/* Merge overlapping EET spells, by type applying strict inequality otherwise rows will match to themselves
---------------------------------------------------------------------*/

;WITH start_dates AS (
			SELECT snz_uid
					,dob
					,[start_date]
					,spell_type
			FROM #EET a
			WHERE NOT EXISTS (SELECT 1 
								FROM #EET  b 
								WHERE a.snz_uid = b.snz_uid 
									AND DATEADD(DAY, -1, a.start_date) <= b.end_date
									AND a.[start_date] > b.[start_date] 
									AND a.spell_type = b.spell_type
									)
			),
end_dates AS (
			SELECT snz_uid
					,dob
					,end_date
					,spell_type
			FROM #EET a
			WHERE NOT EXISTS (SELECT 1 
								FROM #EET b 
								WHERE a.snz_uid = b.snz_uid 
									AND DATEADD(DAY, 1, a.end_date) >= b.start_date
									AND a.[end_date] < b.[end_date]
									AND a.spell_type = b.spell_type
									)
			)

SELECT a.snz_uid
		,a.dob
		,a.[start_date] AS [linked_start]
		,MIN(b.[end_date]) AS [linked_end]
		,a.spell_type
INTO #EET_linked
FROM start_dates a
LEFT JOIN end_dates b
ON a.snz_uid = b.snz_uid
	AND a.[start_date] <=b.end_date
	AND a.spell_type = b.spell_type
GROUP BY a.snz_uid,a.dob,a.start_date,a.spell_type;

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_20506];

/* Adding in a single entity for MOE spells */
/*<!*/
SELECT DISTINCT a.snz_uid
	, a.dob
	, a.linked_start as start_date
	, a.linked_end as end_date 
	, a.spell_type
	, MAX(b.entity) as entity
/*<cm_output_start>*/
INTO [SIA_Sandpit].[DL-MAA2023-46].[EET_spells_202506]
/*<cm_output_end>*/
FROM #EET_Linked a
INNER JOIN #pop p on a.snz_uid = p.snz_uid
LEFT JOIN #EET b on a.snz_uid = b.snz_uid AND a.linked_start <=  b.end_date AND b.start_date <= a.linked_end
GROUP BY a.snz_uid
	, a.dob
	, a.linked_start
	, a.linked_end
	, a.spell_type
/*!>*/
/*<ft_code_end_eet_flexible>*/
;


