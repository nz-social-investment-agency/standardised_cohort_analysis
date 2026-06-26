/***************************************************************************************************************************

<< Dynamically generated text >>

# Outputs:
**SQL:** [IDI_Community].[dsbl_autism].[autism_$(REFRESH)]
**SAS:** libname cm_autism dsn=idi_community_srvprd schema=dsbl_autism; run ;

# Inputs:
[IDI_Clean_$(REFRESH)].[acc_clean].[claims]                                          (Source dependency)
[IDI_Clean_$(REFRESH)].[acc_clean].[medical_codes]                                   (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_diag]                   (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[priv_fund_hosp_discharges_diag]                  (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[mortality_diagnosis]                             (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[socrates_disability]                             (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[socrates_referral]                               (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[socrates_needs_ass]                              (Source dependency)
[IDI_Adhoc].[clean_read_MOH_PRIMHD].[primhd_diagnoses_202510]                    (Source dependency)
[IDI_Adhoc].[clean_read_MOH_PRIMHD].[moh_primhd_mhinc]                           (Source dependency)
[IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs]                             (Source dependency)
[IDI_Clean_$(REFRESH)].[dia_clean].[deaths]                                          (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_event]                  (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[priv_fund_hosp_discharges_event]                 (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[mortality_registrations]                         (Source dependency)
[IDI_Clean_$(REFRESH)].[moh_clean].[pop_cohort_demographics]                         (Source dependency)
[IDI_Clean_$(REFRESH)].[security].[concordance]                                      (Source dependency)
[IDI_Clean_$(REFRESH)].[data].[personal_detail]                                      (Source dependency)

<< Dynamically generated text >>

<div data-theme-toc="true"></div>

# Output path
>**SQL:**[IDI_Community].[dsbl_autism].[autism_YYYYMM]
>**SAS:** libname cmid dsn=idi_community_srvprd schema=dsbl_autism; run ;
>**How to access a code module in the Data Lab**:[Read here](https://idcommons.discourse.group/t/how-to-access-a-code-module-in-the-data-lab/658)

# Description
The purpose of this code module is to identify individuals in New Zealand in the IDI who have a recorded diagnosis of autism.  

The dataset will list individuals, the earliest event when an individual has a recorded diagnosis of autism in the IDI, date of the earliest event, the individual's age and whether they are alive at the time of the IDI refresh.  For those individuals who have died, the dataset lists a date of death and age at death.

This module is not intended to be used to give a true prevalence rate of people in New Zealand on the autism spectrum due to limitations of the datasets included in the IDI. The code module allows researchers to have a consistent way of identifying people on the autism spectrum and will allow for comparisons of outcomes for people with autism and people without autism.

## Key Concepts

* Individuals are identified from a diagnosis recorded using a recognised ICD-9-CM-A diagnosis code for autism or a diagnosis recorded through other means by a professional.
* An individual may have multiple entries in a source dataset or across a number of source datasets.
* This module collates the earliest reference to the individual with an appropriate diagnosis in each source dataset and then identifies the earliest reference amongst all datasets.
* The module indicates whether the individual was alive at the time of the most recent IDI refresh.
* The module will record events within the time period that data is included in the IDI. 
* The earliest date recorded in the IDI is not a date of diagnosis or onset of a condition.

## Business history

### Code history and ICD code notes

ICD codes used are based on the ICD clinical code system for the earliest date of data as per Health New Zealand (HNZ) | Te Whatu Ora best practice. This means ICD-9-CM-A codes have been used in line with the start of the health-related datasets in the IDI. 

On advice from HNZ clinical coding/classification staff, codes have first been looked up directly in ICD-10-AM 12th Edition (current Edition used), then back mapped to ICD-10-AM 1st Edition and then back mapped to ICD-9-CM-A codes.  

ICD-9-CM-A codes have also been added to ensure coverage if the diagnosis was coded in ICD-9-CM-A using the latest ICD classification definitions (see Table 1).

Due to the nature of how clinical coding and classifications using ICD codes work, there are some instances where ICD-10-AM 1st Edition codes back map to ICD-9-CM-A codes that may include more than just the intended diagnosis for this code module due to changes and decisions made with ICD code mapping overtime (see Table 2).

#### Notes for specific datasets 
* For NMDS publicly funded and privately funded hospital discharge datasets, individuals are identified by ICD codes backmapped to ICD-9-CM-A and the more recent ICD-10-AM editions where backmapping appears to not have occured. 

* For the MORT dataset, ICD codes have only been provided in their submitted system codes (i.e. not backmapped). This means the source dataset includes both ICD-9-CM-A and editions of ICD-10-AM and the code underlying this module has been written to reflect this.

* For the PRIMHD dataset, codes have been provided in DSM-IV and ICD-10-AM edition codes. This means the source dataset includes both DSM-IV and ICD-10-AM editions and the code underlying this module has been written to reflect this.

* For the MHINC dataset, codes have been provided in various ICD code editions as well as backmapping to DSM-IV where possible. This means the source dataset includes both DSM-IV and ICD-9-CM-A and the code underlying this module has been written to reflect this.

## References
1. Beltran-Castillon L and McLeod K (2023) From Data to Dignity: Health and Wellbeing Indicators for New Zealanders with Intellectual Disability. Published: IHC, K?t?t? Insight
2. Stats NZ (2025) Household Disability Survey 2023 - findings, definitions, and design summary.
3. Bowden et al (2020) Autism spectrum disorder / Takiw?tanga: An Integrated Data Infrastructure - based approach to autism spectrum disorder research in New Zealand.
4. Ministry of Health (2024) New Zealand Health Survey 2023/24 - Annual Data Explorer.

# Community of Interest

|Domain                     |Agency				                        |Person		        |
|---------------------------|-------------------------------------------|-------------------|
|Initial code               | Social Investment Agency (SIA)         	|Craig Wright       |
|Module coder               | Whaikaha - Ministry of Disabled People    |Adelaide Wilson    |
|Module coder               | Nicholson Consulting                      |Sarah Underwood    |
|Lead SME/Policy            | Whaikaha - Ministry of Disabled People    |Michelle Gezentsvey, Claire Bretherton|

# Key business rules

|Dataset name                        |Diagnosis definition			                                                         |Dataset time period           |
|------------------------------------|---------------------------------------------------------------------------------------|------------------------------|
|Accident Compensation Corporation (ACC) Injury Claims Data   |Recorded as having an ACC read code on the ACC45 claim form of:                         | 1974 -		                |
||||
|            | 'Eu840' (Autistic disorder of childhood onset),                                        |                              |
|                                    | 'E1400' (Active infantile autism),                                                     |                              |
|                                    | 'E1401' (Residual infantile autism),                                                   |                              |
|                                    | 'Eu841' (Atypical autism), or                                                           |                              |
|                                    | 'E140.' (Infantile autism).                                                             |                              |                                         
|                                    |                                                                                       |                              |
|Publicly funded hospital discharges (NMDS) |A publicly funded hospital discharge with a primary or secondary **ICD-9-CM-A** diagnosis code of:  | 1988 -                        |
|                              |                                                                               |                              |
|                                    | 29900 (Infantile autism, current or active state),                                    |                              |
|                                    | 29901 (Infantile autism, residual state),                                             |                              |
|                                    | 29990 (Unspecified childhood psychosis, current or active state),    |                              |
|                                    | or an **ICD-10-CM-A** diagnosis code starting with:                                    |                              |
|                                    |   F84 (Autism spectrum disorder).                                                                                      |                              |
| | |  |
|Privately funded hospital discharges (NMDS)|A privately funded hospital discharge with a primary or secondary **ICD-9-CM-A** diagnosis code of: | 2001 -                        |
|                              |                                                                               |                              |
|                                    | 29900 (Infantile autism, current or active state),                                    |                              |
|                                    | 29901 (Infantile autism, residual state),                                             |                              |
|                                    | 29990 (Unspecified childhood psychosis, current or active state),   |                              |
|				                     | or an **ICD-10-CM-A** diagnosis code starting with:                                       |                              |
|			                         | F84 (Autism spectrum disorder).                                                                                      |                              |
||||
|Mortality Collection (MORT)         |Identified as an underlying or contributing cause of death with a  **ICD-9-CM-A** diagnosis code of: | 1988 -                        |
|                                    |                                                                                |                              |
|                                    | 29900 (Infantile autism, current or active state),                                    |                              |
|                                    | 29901 (Infantile autism, residual state),                                             |                              |
|                                    | 29990 (Unspecified childhood psychosis, current or active state),     |                              |
|                                    | or an **ICD-10-CM-A** diagnosis code starting with:                                     |                              |
|                                    |  F84 (Autism spectrum disorder).                                                                                     |                              |
||||
|Disability Support Services database (SOCRATES) |Recorded as having autism in the Referral Diagnosis/Health Condition field with the code of:  | 1998 -                        |
|		                 |                                                                    |                              |
|                                    | 1206 (Asperger's syndrome),                                                           |                              |
|                                    | 1211 (Autistic Spectrum Disorder(ASD)),  or                                             |                              |
|				                     | 1207 (Retired - Other autistic spectrum disorder (ASD)).                               |                              |
|                                    |                                                                                       |                              |
|Programme for the Integration of Mental Health Data (PRIMHD)   |A diagnosis in the **DSM-IV** classification system in secondary mental health and addiction services with a code of:        | 2009 -                        |
|         |                                                    |                              |
|                                    |29900 (Autistic disorder),                  |                              |
|                                    |or an **ICD-10-AM (12th Edition)** diagnosis code starting with:                                                          |                              |
|				                     | F84 (Autism spectrum disorder).                                                                                      |                              |
|		                             |	            	                                                                     |                              |
|Mental Health Information National Collection (MHINC)  |A diagnosis in the **DSM-IV** classification system in secondary mental health and addiction services with a code of:       | July 2001 - 2008               |
|                  |                                                     |                              |
|                                    | 29900 (Autistic disorder), 
|                                   |      or an **ICD-9-CM-A** diagnosis code of:                        |
|                                    | 29900 (Infantile autism, current or active state),                                    |                              |
|                                    | 29901 (Infantile autism, residual state),                                             |                              |
|                                    | 29990 (Unspecified childhood psychosis, current or active state),      |                              |
|                                    |    or an **ICD-10-AM (12th Edition)** diagnosis code starting with:                                                                                 |                              |
||F84 (Autism spectrum disorder). |
||||
|Oranga Tamariki Gateway Assessments Data |A need type of Autism Spectrum Disorder in a Gateway Assessment.                        | 2013 -                        |
|                                |                                                                                       |                              |

## Table 1: ICD-9-CM-A codes included to ensure coverage if coding in ICD-9-CM-A – includes forward/backward map to ICD-10-AM 1st Edition

To ensure coverage when using ICD-9-CM-A codes, the following codes are noted to forward/backward map to ICD-10-AM 1st Edition.

Note:
Forward mapping provides equivalent codes for deleted codes in the newer edition
Backward mapping provides equivalent codes for new codes in the newer edition.

|ICD-9-CM-A code and definition           |  ICD-10-AM 1st Edition code and definition   |
|-------------------------------------------|-----------------------------------------------|
|29900 Infantile autism, current or active state        |  F840 Childhood autism                       |                                    |                                              |
|29901 Infantile autism, residual state   |  F840 Childhood autism                       |

## Table 2: ICD-10-AM 1st Edition codes that back map to ICD-9-CM-A codes included in the code module

|ICD-9-CM-A code and definition           |  ICD-10-AM 1st Edition code and definition   |
|-----------------------------------------|-------------------------------------------------|
|29990 Unspecified childhood psychosis, current or active state   |  F845 Asperger's syndrome                    |
    
# Data quality and other known issues
1. Not all individuals in New Zealand diagnosed with autism will be identified in this module.  The module requires that the individual has had an ACC claim form, hospital discharge events, received mental health or Disability Support Services, an Oranga Tamariki gateway assessment, or had their death recorded, where the diagnosis of autism has been specified.

2. Datasets included have different lag times for having updated data available in the IDI. This means the completeness of the data at the time of analysis will depend on the lag time of the different datasets.

3. Individuals identified in the SOCRATES disability dataset do not always appear in the referral or needs assessment datasets as well.  Where an individual is only identified through the SOCRATES disability dataset there is no associated event date.  In this case a proxy date of '3999-12-31' will be seen in the final table.

4. While some individuals with autism will be diagnosed in early childhood, others may not be diagnosed until later or be identified in the IDI until later (Bowden et al, 2020).  Thus there will be delay in data entering the IDI for individuals as well as datasets.  

5. Registerable stillbirths are included in the mortality dataset. 

## Comparison against other sources
* Counts of individuals published in the IHC publication 'From Data to Dignity', (2023) were for those individuals with autism in the study population defined as the 2018 Administrative Population Census (APC).The counts from this code module for people with autism are slightly lower than those in the 2023 publication.  

* Counts from the latest Stats NZ Household Disability Survey (HDS) estimated that 2% of the New Zealand population aged 5 years and over living in New Zealand households had a diagnosis of autism (Stats NZ, 2025). This equates to around 72,000 people. In comparison with the HDS, this module has a lower count.

* Data from the 2023/24 New Zealand Health Survey (NZHS) estimates the prevalence of diagnosed autism in children aged 2 to 14 years old to be 3%, equating to 26,000 children (Ministry of Health, 2024). This module significantly undercounts for this age group.

# Parameters
The following parameters should be supplied to this module to run it in the database:

1. {targetdb}: The SQL database on which the dataset is to be created. 
2. {idicleanversion}: The IDI Clean version that the dataset needs to be based on.
3. {targetschema}: The project schema under the target database into which the dataset is to be created.

# Dependencies
```
{idicleanrefresh}.[acc_clean].[claims]
{idicleanrefresh}.[acc_clean].[medical_codes]
{idicleanrefresh}.[moh_clean].[pub_fund_hosp_discharges_diag]
{idicleanrefresh}.[moh_clean].[pub_fund_hosp_discharges_event]
{idicleanrefresh}.[moh_clean].[priv_fund_hosp_discharges_diag]
{idicleanrefresh}.[moh_clean].[priv_fund_hosp_discharges_event]
{idicleanrefresh}.[moh_clean].[mortality_diagnosis]
{idicleanrefresh}.[moh_clean].[mortality_registrations]
{idicleanrefresh}.[moh_clean].[socrates_disability]
{idicleanrefresh}.[moh_clean].[socrates_needs_ass]
{idicleanrefresh}.[moh_clean].[socrates_referral]
{idicleanrefresh}.[security].[concordance]
{idicleanrefresh}.[data].[personal_detail]
{idicleanrefresh}.[dia_clean].[deaths]
{idicleanrefresh}.[moh_clean].[pop_cohort_demographics]
```
The following IDI_Adhoc are the most recent versions for this current refresh but changes to the code will need to be made as new datasets are uploaded into the IDI.
```
[IDI_Adhoc].[clean_read_MOH_PRIMHD].[primhd_diagnoses_202510]
[IDI_Adhoc].[clean_read_MOH_PRIMHD].[moh_primhd_mhinc]
[IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs]
```
# Outputs
```
{targetdb}.{targetschema}.autism
```
|Column name		    |Description                                                                                                                       |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------|
|snz_uid		        |The unique Stats NZ person identifier for the the individual                                                                      |
|type	            	|A string indicating which condition or disability this table has identified (hard-coded to "AUT")                                 |				  
|entity			        |A string indicating the organisation or provider ID that has provided a service for mental health services, where relevant        |
|source_table           |A string that states the data source for the earliest record of diagnosis for an individual in the IDI                            |
|min_date               |The earliest record of diagnosis for an individual in the IDI (Note: not a date of diagnosis or onset of a condition)             |                                                                                                                                                                                                                                             |
|snz_sex_gender_code    |Code for an individual's gender                                                                                                   |
|snz_birth_month_nbr    |Month of an individual's birth                                                                                                    |
|snz_birth_year_nbr     |Year of an individual's birth                                                                                                     |
|snz_birth_date_proxy   |Proxy date of an individual's birth                                                                                               |
|age                    |Age of an individual at the time of the IDI refresh                                                                               |
|death_status           |A binary indicator indicating whether an individual is recorded dead (value = 1) or alive (value = 0) at the time of refresh               |
|snz_deceased_year_nbr  |Year of an individual's death (if relevant)                                                                                       |
|snz_deceased_month_nbr |Month of an individual's death (if relevant)                                                                                      |
|dod                    |Date of death (if relevant)                                                                                                       |
|age_at_death	        |Age of an individual at death (if relevant)                                                                                       |

# Variable descriptions
**Granularity:** 
One row represents an individual, the earliest identification of their diagnosis in the IDI, birthdate, gender and death (if applicable). 

# Module Version & Change History

|Date               |Version 	|Comments                                                                                   |                  
|-------------------|-----------|-------------------------------------------------------------------------------------------|
|26 May 2025	    |Initial	|Version based on specifications from Commissioning document                                |                         
|09 June 2025       |       1.1 |Update to ACC variable with 202506 refresh. acc_med_read_code updated to acc_med_injury_code and acc_cla_read_code to acc_cla_primary_inj_code with acc_cla_primary_inj_type_code added. |
|31 October 2025	|1.2		|Update to MoH publicly funded hospital discharge variable with 202510 refresh. Converted moh_evt_evst_date from datetime to date.|
|19 November 2025| 1.3 |Update to latest PRIMHD diagnoses 202510 ad hoc table. Update to SOCRATES tables location and names and variable names and from 202510 refresh.|

# Code

***************************************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

/*Set Parameters*/
/*Ref date should be the 15th of the month of the refresh used*/
:SETVAR refdate "2025-12-31"

USE $(PROJECT_DB);
GO

/*ACC claims with a code that refers to autism*/
/*<ft_code_start_autism>*/
DROP TABLE IF EXISTS #acc_asd;
SELECT
c.snz_uid
,'ACC' AS source_table
,c.code
,c.date AS event_date
,CAST(NULL AS VARCHAR(10)) AS entity
INTO #acc_asd
FROM 
(
SELECT 
[snz_uid]
,[acc_cla_accident_date] AS date
,[acc_cla_primary_inj_code] AS code
FROM  [IDI_Clean_$(REFRESH)].[acc_clean].[claims]
      WHERE ([acc_cla_primary_inj_code] IN ('Eu841', 'E140.','E1400', 'E1401', 'Eu840') AND [acc_cla_primary_inj_type_code] = 'Read Code')
UNION ALL  
SELECT 
b.snz_uid
,b.acc_cla_accident_date AS date
,a.[acc_med_injury_code] AS code
FROM  [IDI_Clean_$(REFRESH)].[acc_clean].[medical_codes] AS a
      LEFT JOIN [IDI_Clean_$(REFRESH)].[acc_clean].[claims] AS b ON a.[snz_acc_claim_uid] = b.[snz_acc_claim_uid]
      WHERE  a.[acc_med_injury_code] IN ('Eu841', 'E140.','E1400', 'E1401', 'Eu840')
      ) AS c;

/*Public hospital discharges where clinical code matches a diagnosis of autism */

DROP TABLE IF EXISTS #moh_pub_asd;
SELECT 
b.snz_uid
,'MOH_PUB' AS source_table
,a.[moh_dia_submitted_system_code]
,a.[moh_dia_diagnosis_type_code]
,a.[moh_dia_event_id_nbr]
,a.[moh_dia_clinical_code]
,b.[moh_evt_birth_year_nbr]
,CAST (b.[moh_evt_evst_date] AS DATE) AS event_date
,CAST (NULL AS VARCHAR(10)) AS entity
INTO #moh_pub_asd
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_diag] AS a
     LEFT JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_event] AS b ON a.moh_dia_event_id_nbr = b.moh_evt_event_id_nbr
     WHERE (SUBSTRING(a.[moh_dia_clinical_code],1,5) IN ('29900','29901','29990') AND a.[moh_dia_clinical_sys_code] = '06' AND a.[moh_dia_diagnosis_type_code] IN  ('A','B'))
	 OR (SUBSTRING(a.[moh_dia_clinical_code],1,3) IN ('F84') AND a.[moh_dia_clinical_sys_code] >= '10' AND a.[moh_dia_diagnosis_type_code] IN ('A','B'));  

/*Private hospital discharges where clinical code matches a diagnosis of autism */

DROP TABLE IF EXISTS #moh_pri_asd;
SELECT 
b.snz_uid
,'MOH_PRI' AS source_table
,a.[moh_pri_diag_event_id_nbr]
,a.[moh_pri_diag_clinic_sys_code]
,a.[moh_pri_diag_sub_sys_code]
,a.[moh_pri_diag_diag_type_code]
,a.[moh_pri_diag_clinic_code] 
,b.[moh_pri_evt_start_date] AS event_date
,CAST (NULL AS VARCHAR(10)) AS entity
INTO #moh_pri_asd
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[priv_fund_hosp_discharges_diag] AS a
     LEFT JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[priv_fund_hosp_discharges_event] AS b ON a.moh_pri_diag_event_id_nbr = b.moh_pri_evt_event_id_nbr
     WHERE (SUBSTRING(a.[moh_pri_diag_clinic_code],1,5) IN ('29900','29901','29990') AND a.[moh_pri_diag_clinic_sys_code] = '06' AND a.[moh_pri_diag_diag_type_code] IN ('A','B'))
     OR (SUBSTRING(a.[moh_pri_diag_clinic_code],1,3) IN ('F84') AND a.[moh_pri_diag_clinic_sys_code] >= '10' AND a.[moh_pri_diag_diag_type_code] IN ('A','B'));


/*Registrations in the mortality dataset where clinical code matches a diagnosis of autism */

DROP TABLE IF EXISTS #mos_asd;
SELECT
b.[snz_uid]
,b.[snz_moh_uid]
,'MOH_MOS' AS source_table
,DATEFROMPARTS(b.moh_mor_birth_year_nbr,b.moh_mor_birth_month_nbr,15) AS event_date
,a.[moh_mort_diag_clinical_code] AS code
,a.[moh_mort_diag_clinic_type_code]
,a.[moh_mort_diag_clinic_sys_code]
,a.[moh_mort_diag_diag_type_code]
,CAST (NULL AS VARCHAR(10)) AS entity
 INTO #mos_asd
 FROM [IDI_Clean_$(REFRESH)].[moh_clean].[mortality_diagnosis] AS a
      LEFT JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[mortality_registrations] AS b ON a.[snz_dia_death_reg_uid] = b.[snz_dia_death_reg_uid]
      WHERE (SUBSTRING(a.[moh_mort_diag_clinical_code],1,5) IN ('29900','29901','29990') AND a.[moh_mort_diag_clinic_sys_code] = '06')
      OR (SUBSTRING(a.[moh_mort_diag_clinical_code],1,3) IN ('F84') AND a.[moh_mort_diag_clinic_sys_code] >= '10');



/* individuals in the Ministry of Health SOCRATES database with code 1211, 1206 and 1207. Date can either be first contact date or referral date.
Where an individual appears only in the disability table but not the needs assessment or referral table, an event date of 3999-12-31 is added.
This date will be removed in the collation process if the individual appears in other datasets with an earlier event_date or kept if the 
diagnosis table is the only record for the individual*/


DROP TABLE IF EXISTS #moh_soc_asd;
SELECT
DISTINCT
b.snz_uid
,'SOC' AS source_table
,CASE WHEN d.[soc_needs_ass_first_cont_date] IS NOT NULL THEN d.[soc_needs_ass_first_cont_date] 
	  WHEN c.[soc_referral_first_contact_date] IS NOT NULL THEN c.[soc_referral_first_contact_date]
	  WHEN c.[soc_referral_referral_date] IS NOT NULL THEN c.[soc_referral_referral_date]
	  WHEN c.[soc_referral_referral_date] IS NULL AND c.[soc_referral_first_contact_date] IS NULL AND d.[soc_needs_ass_first_cont_date] IS NULL THEN '3999-12-31'
	  END AS event_date
,CAST (a.soc_dis_code as VARCHAR(7)) AS code
,a.[soc_dis_desc_text] as Description
,CAST (NULL AS VARCHAR(10)) AS entity
INTO #moh_soc_asd
FROM IDI_Clean_$(REFRESH).[moh_clean].[socrates_disability] AS a 
      LEFT JOIN IDI_Clean_$(REFRESH).[moh_clean].[pop_cohort_demographics] AS b ON a.snz_moh_uid = b.snz_moh_uid 
      LEFT JOIN (SELECT DISTINCT snz_moh_uid,[soc_referral_first_contact_date], [soc_referral_referral_date] FROM IDI_Clean_$(REFRESH).[moh_clean].[socrates_referral]) AS c ON a.snz_moh_uid = c.snz_moh_uid 
	  LEFT JOIN (SELECT DISTINCT snz_moh_uid,[soc_needs_ass_first_cont_date] FROM IDI_Clean_$(REFRESH).[moh_clean].[socrates_needs_ass]) AS d ON a.snz_moh_uid = d.snz_moh_uid 
      WHERE a.soc_dis_code IN ('1211','1206','1207');


/*Autism diagnosis in PRIMHD diagnosis data*/

DROP TABLE IF EXISTS #moh_PRIMHD_asd;
SELECT
 b.snz_uid
,a.[snz_moh_uid]
,'MOH_PRIMHD' AS source_table
,CAST (a.[organisation_id] AS VARCHAR(10)) AS entity
,a.[classification_code_id]
,a.[diagnosis_type]
,CONVERT(date,a.[classification_start_date],103) AS event_date
,a.[clinical_coding_system_id]
,a.[clinical_code] AS code
INTO #moh_PRIMHD_asd
/*
	NOTE TO DEVELOPERS: The following line contains a reference to a fixed 202510 refresh table. 
	Does this need to be updated every refresh?
*/
FROM [IDI_Adhoc].[clean_read_MOH_PRIMHD].[primhd_diagnoses_202510] AS a
     LEFT JOIN [IDI_Clean_$(REFRESH)].[moh_clean].[pop_cohort_demographics] AS b ON a.snz_moh_uid = b.snz_moh_uid
	 WHERE (SUBSTRING(a.[clinical_code],1,5) IN ('29900') AND a.[clinical_coding_system_id] = '07')
	 OR (SUBSTRING(a.[clinical_code],1,3) IN ('F84') AND a.[clinical_coding_system_id] >= '10') ;


 /* Autism diagnosis in PRIMHD MHINC data*/

DROP TABLE IF EXISTS #moh_mhinc_asd;
SELECT
b.snz_uid
,'MOH_MHINC' AS source_table
,CAST (a.[organisation_id] AS VARCHAR(10)) AS entity
,a.[classification_start] AS event_date
,a.[clinical_coding_system_id]
,a.[clinical_code] AS code
,a.[diagnosis_type]
INTO #moh_mhinc_asd
FROM [IDI_Adhoc].[clean_read_MOH_PRIMHD].[moh_primhd_mhinc] AS a
     LEFT JOIN [IDI_Clean_$(REFRESH)].[security].[concordance] AS b ON a.snz_moh_uid = b.snz_moh_uid
     WHERE (SUBSTRING(a.[clinical_code],1,5) IN ('29900','29901','29990') AND a.[clinical_coding_system_ID] = '06')
	 OR (SUBSTRING(a.[clinical_code],1,5) IN ('29900') AND a.[clinical_coding_system_ID] = '07')
     OR (SUBSTRING(a.[clinical_code],1,3) IN ('F84') AND a.[clinical_coding_system_ID] >= '10') ;


/* Autism spectrum disorder as a client need in gateway assesssments*/

DROP TABLE IF EXISTS #cyf_gateway_asd;
SELECT
b.snz_uid
,a.snz_msd_uid
,a.[need_type_code]
,a.[needs_desc]
,a.[need_category_code] AS code
,a.[needs_cat_desc]
,needs_created_date AS event_date
,'CYF' AS source_table
, CAST (NULL AS VARCHAR (10)) AS entity
INTO #cyf_gateway_asd
FROM [IDI_Adhoc].[clean_read_CYF].[cyf_gateway_cli_needs_202511] AS a
     LEFT JOIN [IDI_Clean_$(REFRESH)].security.concordance AS b  ON a.snz_msd_uid = b.snz_msd_uid
     WHERE need_type_code IN ('AUT182');

/* collate data from all sources into one table*/

DROP TABLE IF EXISTS #asd;
SELECT
a.snz_uid 
,MIN(event_date) AS min_date
,source_table
,entity
INTO #asd
FROM (
SELECT snz_uid, event_date, source_table, entity FROM #acc_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #moh_pub_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #moh_pri_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #mos_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #moh_soc_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #moh_primhd_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #moh_mhinc_asd
UNION ALL
SELECT snz_uid, event_date, source_table, entity FROM #cyf_gateway_asd
)  AS a
GROUP BY snz_uid
,source_table
,entity;

/* subset of individuals who are deceased and are in death data*/

DROP TABLE IF EXISTS #asd_dd;
SELECT 
a.*
,b.snz_birth_month_nbr
,b.snz_birth_year_nbr
,b.snz_sex_gender_code
,b.snz_deceased_year_nbr
,b.snz_deceased_month_nbr
,b.snz_birth_date_proxy
,NULL AS age
,DATEFROMPARTS(b.snz_deceased_year_nbr, b.snz_deceased_month_nbr, 15) AS dod
,'AUT' AS [type]
INTO #asd_dd
FROM #asd as a
      INNER JOIN [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS b ON a.snz_uid = b.snz_uid
      WHERE a.snz_uid IN (SELECT DISTINCT snz_uid FROM [IDI_Clean_$(REFRESH)].[dia_clean].[deaths])
      AND b.snz_deceased_year_nbr IS NOT NULL;

/* subset of individuals who are deceased but not in death data*/

DROP TABLE IF EXISTS #asd_od;
SELECT
a.*
,b.snz_birth_month_nbr
,b.snz_birth_year_nbr
,b.snz_sex_gender_code
,b.snz_deceased_year_nbr
,b.snz_deceased_month_nbr
,b.snz_birth_date_proxy
,NULL AS age
,DATEFROMPARTS(b.snz_deceased_year_nbr, b.snz_deceased_month_nbr, 15) AS dod
,'AUT' AS [type]
INTO #asd_od
FROM #asd AS a
    INNER JOIN [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS b ON a.snz_uid = b.snz_uid
    WHERE a.snz_uid NOT IN (SELECT DISTINCT snz_uid FROM [IDI_Clean_$(REFRESH)].[dia_clean].[deaths])
    AND b.snz_deceased_year_nbr IS NOT NULL;


/* subset of individuals who are alive*/

DROP TABLE IF EXISTS #asd_ad;
SELECT 
a.*
,b.snz_birth_month_nbr
,b.snz_birth_year_nbr
,b.snz_sex_gender_code
,b.snz_deceased_year_nbr
,b.snz_deceased_month_nbr
,b.snz_birth_date_proxy
,DATEDIFF(YEAR, b.snz_birth_date_proxy, '$(refdate)') AS age 
,'3999-12-31' AS dod 
,'AUT' AS [type]
 INTO #asd_ad
 FROM #asd AS a
 INNER JOIN [IDI_Clean_$(REFRESH)].[data].[personal_detail] AS b ON a.snz_uid = b.snz_uid
 WHERE a.snz_uid NOT IN (SELECT DISTINCT snz_uid FROM [IDI_Clean_$(REFRESH)].[dia_clean].[deaths])
 AND a.snz_uid NOT IN (SELECT DISTINCT snz_uid FROM #asd_dd)
 AND a.snz_uid NOT IN (SELECT DISTINCT snz_uid FROM #asd_od);
  

 /* join all tables together*/

DROP TABLE IF EXISTS #asd_final;
WITH asd_union AS (
SELECT
* 
FROM #asd_dd
UNION ALL
SELECT * FROM #asd_od
UNION ALL
SELECT * FROM #asd_ad
)

SELECT
* 
,DATEDIFF(YEAR, snz_birth_date_proxy, dod) AS age_at_death
,CASE WHEN age IS NOT NULL THEN 0 ELSE 1 END AS death_status
INTO #asd_final
FROM asd_union;


/* select all required variables */
DROP TABLE IF EXISTS #asd_min;
SELECT 
snz_uid
,[type]
,entity
,source_table
,min_date
,snz_sex_gender_code
,snz_birth_month_nbr
,snz_birth_year_nbr
,snz_birth_date_proxy
,age
,death_status
,snz_deceased_year_nbr
,snz_deceased_month_nbr
,CASE WHEN dod = '3999-12-31' THEN NULL ELSE dod END AS dod
,CASE WHEN age_at_death > 1000 THEN NULL ELSE age_at_death END AS age_at_death
INTO #asd_min
FROM #asd_final


/*take earliest recorded date for each snz_uid and create table */
DROP TABLE IF EXISTS #asd_dbl;
SELECT 
snz_uid
,[type]
,entity
,source_table
,min_date
,snz_sex_gender_code
,snz_birth_month_nbr
,snz_birth_year_nbr
,snz_birth_date_proxy
,age
,death_status
,snz_deceased_year_nbr
,snz_deceased_month_nbr
,dod
,age_at_death
INTO #asd_dbl
FROM #asd_min a
WHERE min_date = (
SELECT MIN(min_date)
FROM #asd_min b
WHERE b.snz_uid = a.snz_uid)
ORDER BY snz_uid;

/* remove duplicate snz_uid with the same minimum date but different entities or sources. Create table in $(PROJECT_DB) */

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_autism_$(REFRESH)];

WITH cte AS 
(SELECT ROW_NUMBER() OVER(PARTITION BY snz_uid
ORDER BY snz_uid DESC) AS rn
FROM #asd_dbl)
DELETE FROM cte WHERE rn > 1;

/*<!*/
SELECT 
	snz_uid
	,[type]
	,entity
	,source_table
	,min_date
	,snz_sex_gender_code
	,snz_birth_month_nbr
	,snz_birth_year_nbr
	,snz_birth_date_proxy
	,age
	,death_status
	,snz_deceased_year_nbr
	,snz_deceased_month_nbr
	,dod
	,age_at_death
/*<cm_output_start>*/
INTO [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_autism_$(REFRESH)]
/*<cm_output_end>*/
FROM #asd_dbl
/*!>*/
/*<ft_code_end_autism>*/
;

-- Compression
EXEC [IDI_UserCode].[$(PROJECT_SCHEMA)].[compress_table_$(PROJECT_DB)] @table = '[$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_autism_$(REFRESH)]'
GO

CREATE NONCLUSTERED INDEX my_index_name ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_autism_$(REFRESH)] (snz_uid);
GO
