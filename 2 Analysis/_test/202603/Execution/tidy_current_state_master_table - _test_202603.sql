/**************************************************************************************************
Title: Tidy master table for current state analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
Output
- [IDI_UserCode].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]

Intended purpose:
Tidy the master table that will be used for current state results.

Notes:

Parameters & Present values:
	Project database = SIA_Sandpit
	Project schema = DL-MAA2026-04
	Pipeline prefix = CHT_
	Cohort term for injection = _test
	Current refresh = 202603

Issues:
 
History (reverse order):
2026-03-20 CR added single year age, ACES and B4SC measures
2025-08-26 SA version 1
**************************************************************************************************/

USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
GO

CREATE VIEW [DL-MAA2026-04].[CHT__test_current_state_master_table_202603] 
AS
SELECT snz_uid
	, organisation
	, client_status
	, period
	, [current_date]

--- Entity counts for cohort (in case required) ----
	,entity_cohort_mha
	,entity_cohort_edu
	,entity_cohort_pbn
	,entity_cohort_ent

--- Demographics ---

	, dob
	, eth_european
	, eth_maori
	, eth_pacific
	, eth_asian
	, eth_MELAA
	, eth_other
	, sex
	, IIF(disability > 0,disability, 0) AS disability
	, 'New Zealand' as country
	, REGC_current
	, REGC_NAME_current
	, TALB_current
	, TALB_NAME_current
	, SA3_current
	, SA3_NAME_current
	, SA2_current
	, SA2_NAME_current
	, CASE 
		WHEN NZDep_current IN (1,2) THEN 'dep01_02' 
		WHEN NZDep_current IN (3,4) THEN 'dep03_04' 
		WHEN NZDep_current IN (5,6) THEN 'dep05_06' 
		WHEN NZDep_current IN (7,8) THEN 'dep07_08' 
		WHEN NZDep_current IN (9,10) THEN 'dep09_10' 
		END AS deprivation_current
	, CASE WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 0 AND 4 THEN '00-04 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 5 AND 9 THEN '05-09 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 10 AND 14 THEN '10-14 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 15 AND 19 THEN '15-19 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 20 AND 24 THEN '20-24 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 25 AND 29 THEN '25-29 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 30 AND 34 THEN '30-34 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 35 AND 39 THEN '35-39 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 40 AND 44 THEN '40-44 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 45 AND 49 THEN '45-49 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 50 AND 54 THEN '50-54 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 55 AND 59 THEN '55-59 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 60 AND 64 THEN '60-64 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 65 AND 69 THEN '65-69 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 70 AND 74 THEN '70-74 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) BETWEEN 75 AND 79 THEN '75-79 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) >=80 THEN '80 years and over'
		END AS age_band_current
	, FLOOR(DATEDIFF(MONTH,[dob],[current_date])/12) age_current
	, REGC_refdate as REGC
	, REGC_NAME_refdate as REGC_NAME
	, TALB_refdate as TALB
	, TALB_NAME_refdate as TALB_NAME
	, SA3_refdate as SA3
	, SA3_NAME_refdate as SA3_NAME
	, SA2_refdate as SA2
	, SA2_NAME_refdate as SA2_NAME
	, CASE 
		WHEN NZDep_refdate IN (1,2) THEN 'dep01_02' 
		WHEN NZDep_refdate IN (3,4) THEN 'dep03_04' 
		WHEN NZDep_refdate IN (5,6) THEN 'dep05_06' 
		WHEN NZDep_refdate IN (7,8) THEN 'dep07_08' 
		WHEN NZDep_refdate IN (9,10) THEN 'dep09_10' 
		END AS deprivation
	, CASE WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 0 AND 4 THEN '00-04 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 5 AND 9 THEN '05-09 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 10 AND 14 THEN '10-14 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 15 AND 19 THEN '15-19 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 20 AND 24 THEN '20-24 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 25 AND 29 THEN '25-29 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 30 AND 34 THEN '30-34 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 35 AND 39 THEN '35-39 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 40 AND 44 THEN '40-44 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 45 AND 49 THEN '45-49 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 50 AND 54 THEN '50-54 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 55 AND 59 THEN '55-59 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 60 AND 64 THEN '60-64 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 65 AND 69 THEN '65-69 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 70 AND 74 THEN '70-74 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 75 AND 79 THEN '75-79 years'
		WHEN FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) >=80 THEN '80 years and over'
		  END AS age_band
	, FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) AS age
	--, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) = 4,1, NULL) AS age_is4 --for b4sc
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) < 6,1, NULL) AS age_lessthan6 --for ECE
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) >= 5,1, NULL) AS age_atleast5 --for school
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) >=12,1 ,NULL) AS age_atleast12 -- age of criminal responsibilty for serious offences so for police etc	
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) < 16,1, NULL) AS age_lessthan16 --for school etc // possibly not useful //
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) BETWEEN 5 AND 18,1, NULL) AS age_school --for school enrol & attendance etc
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) >= 16,1, NULL) AS age_atleast16 -- for drivers lic,tertiary, qualifications, benefits (including 16 to scoop up youth benefits)
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) < 18,1, NULL) AS age_lessthan18 --for OT
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],[reference_date])/12) >= 18,1, NULL) AS age_atleast18 -- for corrections,main (non youth) benefits etc
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],IIF([max_date_NEET_date] < [reference_date],[max_date_NEET_date],[reference_date])) /12) BETWEEN 15 AND 24,1, NULL) AS age_youth --for NEET 
	, IIF(FLOOR(DATEDIFF(MONTH,[dob],IIF([max_date_MOH_immunisations_date] < [reference_date],[max_date_MOH_immunisations_date], [reference_date])) / 12) BETWEEN 5 AND 18,1,NULL) AS age_imms -- for immunisations, min date for data is 2007
	
	, 1 AS [Standard] -- denominator for all people, when no subset applies

-- Whanau ---

	, IIF(youngest_child_birth_mother_current > dob,1, NULL) AS younger_sibling_mother_current 
	, IIF(youngest_child_birth_father_current  > dob,1, NULL) AS younger_sibling_father_current 

--- Supporting People in to Work ---
	, IIF(main_benefit_duration_12mo > 0 ,1, NULL) AS main_benefit_12mo 
	, IIF(main_benefit_duration_12mo > 180 ,1, NULL) AS main_benefit_6mo_12mo 
	, IIF(main_benefit_duration_mother_12mo > 0 ,1, NULL) AS main_benefit_mother_12mo 
	, IIF(main_benefit_duration_mother_12mo > 180 ,1, NULL) AS main_benefit_mother_6mo_12mo 
	, IIF(main_benefit_duration_father_12mo > 0 ,1, NULL) AS main_benefit_father_12mo 
	, IIF(main_benefit_duration_father_12mo > 180 ,1, NULL) AS main_benefit_father_6mo_12mo 
	, IIF(JSWR_duration_12mo > 0 ,1, NULL) AS JSWR_12mo 
	, IIF(JSWR_duration_12mo > 180 ,1, NULL) AS JSWR_6mo_12mo 
	, IIF(JSWR_duration_mother_12mo > 0 ,1, NULL) AS JSWR_mother_12mo 
	, IIF(JSWR_duration_mother_12mo > 180 ,1, NULL) AS JSWR_mother_6mo_12mo 
	, IIF(JSWR_duration_father_12mo > 0 ,1, NULL) AS JSWR_father_12mo 
	, IIF(JSWR_duration_father_12mo > 180 ,1, NULL) AS JSWR_father_6mo_12mo 
	, IIF(SPS_duration_12mo > 0 ,1, NULL) AS SPS_12mo 
	, IIF(SPS_duration_12mo > 180 ,1, NULL) AS SPS_6mo_12mo 
	, IIF(SPS_duration_mother_12mo > 0 ,1, NULL) AS SPS_mother_12mo 
	, IIF(SPS_duration_mother_12mo > 180 ,1, NULL) AS SPS_mother_6mo_12mo 
	, IIF(SPS_duration_father_12mo > 0 ,1, NULL) AS SPS_father_12mo 
	, IIF(SPS_duration_father_12mo > 180 ,1, NULL) AS SPS_father_6mo_12mo 
	, IIF(employed_duration_12mo > 0 ,1, NULL) AS employed_12mo 
	, IIF(employed_duration_12mo > 180 ,1, NULL) AS employed_6mo_12mo 
	, IIF(employed_duration_mother_12mo > 0 ,1, NULL) AS employed_mother_12mo 
	, IIF(employed_duration_mother_12mo > 180 ,1, NULL) AS employed_mother_6mo_12mo 
	, IIF(employed_duration_father_12mo > 0 ,1, NULL) AS employed_father_12mo 
	, IIF(employed_duration_father_12mo > 180 ,1, NULL) AS employed_father_6mo_12mo 
	, IIF(neet_duration_12mo > 90 ,1, NULL) AS neet_12mo
	, IIF(neet_duration_12mo > 180 ,1, NULL) AS neet_6mo_12mo 
	, IIF(dl_holder_full_current > 0,dl_holder_full_current, NULL) AS dl_holder_full_current
	, IIF(dl_holder_current > 0,dl_holder_current, NULL) AS dl_holder_current
	, IIF(dl_holder_full_mother_current > 0,dl_holder_full_mother_current, NULL) AS dl_holder_full_mother_current
	, IIF(dl_holder_mother_current > 0,dl_holder_mother_current, NULL) AS dl_holder_mother_current
	, IIF(dl_holder_full_father_current > 0,dl_holder_full_father_current, NULL) AS dl_holder_full_father_current
	, IIF(dl_holder_father_current > 0,dl_holder_father_current, NULL) AS dl_holder_father_current
	, IIF(SNG_basics_12mo > 0 ,1, NULL) AS SNG_basics_12mo 
	, IIF(SNG_basics_mother_12mo > 0 ,1, NULL) AS SNG_basics_mother_12mo 
	, IIF(SNG_basics_father_12mo > 0 ,1, NULL) AS SNG_basics_father_12mo
	, IIF(SNG_food_12mo > 0 ,1, NULL) AS SNG_food_12mo 
	, IIF(SNG_food_mother_12mo > 0 ,1, NULL) AS SNG_food_mother_12mo 
	, IIF(SNG_food_father_12mo > 0 ,1, NULL) AS SNG_food_father_12mo

--- Improved Health ---

	, IIF(Hospitalisations_12mo > 0,1, NULL) AS Hospitalisations_12mo
	, IIF(Hospitalisations_mother_12mo > 0,1, NULL) AS Hospitalisations_mother_12mo
	, IIF(Hospitalisations_father_12mo > 0,1, NULL) AS Hospitalisations_father_12mo
	--, IIF(pharmaceutical_dispensing_12mo > 0,1, NULL) AS pharmaceutical_dispensing_12mo
	--, IIF(pharmaceutical_dispensing_mother_12mo > 0,1, NULL) AS pharmaceutical_dispensing_mother_12mo
	--, IIF(pharmaceutical_dispensing_father_12mo > 0,1, NULL) AS pharmaceutical_dispensing_father_12mo
	, IIF(pharmaceutical_drugs_12mo > 0,1, NULL) AS pharmaceutical_drugs_12mo
	, IIF(pharmaceutical_drugs_mother_12mo > 0,1, NULL) AS pharmaceutical_drugs_mother_12mo
	, IIF(pharmaceutical_drugs_father_12mo > 0,1, NULL) AS pharmaceutical_drugs_father_12mo
	, IIF(had_b4sc > 0 , 1, NULL) as had_b4sc -- need clarity on appropriate denominiator, for now use 5 to 18 (data starts 2008)
	, IIF(b4sc_sdq IS NOT NULL , 1, NULL) as had_sdq --denominator
	, IIF(b4sc_peds IS NOT NULL, 1, NULL) as had_peds --denominator
	, IIF(b4sc_sdq >= 17 , 1, NULL) as b4sc_sdq_17_or_over
	, IIF(b4sc_peds IN ('A','B'), 1, NULL) as b4sc_concerning_peds
	, IIF(pho_enrolment_current > 0,pho_enrolment_current, NULL) AS pho_enrolment_current
	, IIF(pho_enrolment_mother_current > 0,pho_enrolment_mother_current, NULL) AS pho_enrolment_mother_current
	, IIF(pho_enrolment_father_current > 0,pho_enrolment_father_current, NULL) AS pho_enrolment_father_current
	, IIF(acc_injuries_12mo > 0,acc_injuries_12mo, NULL) AS acc_injuries_12mo
	, IIF(acc_injuries_mother_12mo > 0,acc_injuries_mother_12mo, NULL) AS acc_injuries_mother_12mo
	, IIF(acc_injuries_father_12mo > 0,acc_injuries_father_12mo, NULL) AS acc_injuries_father_12mo
	, IIF(acc_supports_12mo > 0,acc_supports_12mo, NULL) AS acc_supports_12mo
	, IIF(acc_supports_mother_12mo > 0,acc_supports_mother_12mo, NULL) AS acc_supports_mother_12mo
	, IIF(acc_supports_father_12mo > 0,acc_supports_father_12mo, NULL) AS acc_supports_father_12mo
	, IIF(MHA_service_ever > 0,MHA_service_ever, NULL) AS MHA_service_ever
	, MHA_entity_ever__min
	, MHA_entity_ever__max
	, IIF(MHA_service_mother_ever > 0,MHA_service_mother_ever, NULL) AS MHA_service_mother_ever
	, MHA_entity_mother_ever__min
	, MHA_entity_mother_ever__max
	, IIF(MHA_service_father_ever > 0,MHA_service_father_ever, NULL) AS MHA_service_father_ever
	, MHA_entity_father_ever__min
	, MHA_entity_father_ever__max
	, IIF(MHA_service_12mo > 0,MHA_service_12mo, NULL) AS MHA_service_12mo
	, MHA_entity_12mo__min
	, MHA_entity_12mo__max
	, IIF(MHA_service_mother_12mo > 0,MHA_service_mother_12mo, NULL) AS MHA_service_mother_12mo
	, MHA_entity_mother_12mo__min
	, MHA_entity_mother_12mo__max
	, IIF(MHA_service_father_12mo > 0,MHA_service_father_12mo, NULL) AS MHA_service_father_12mo
	, MHA_entity_father_12mo__min
	, MHA_entity_father_12mo__max
	, IIF(ED_visits_12mo > 0,1, NULL) AS ED_visits_12mo
	, IIF(ED_visits_mother_12mo > 0,1, NULL) AS ED_visits_mother_12mo
	, IIF(ED_visits_father_12mo > 0,1, NULL) AS ED_visits_father_12mo
	, IIF(avoid_hosp_ash_pah_12mo > 0,1, NULL) AS avoid_hosp_ash_pah_12mo
	, IIF(avoid_hosp_ash_pah_mother_12mo > 0,1, NULL) AS avoid_hosp_ash_pah_mother_12mo
	, IIF(avoid_hosp_ash_pah_father_12mo > 0,1, NULL) AS avoid_hosp_ash_pah_father_12mo
	, IIF(full_imms_5yr > 0,1, NULL) AS full_imms_5yr
	, IIF(B4SC_followup > 0,1, NULL) AS B4SC_followup

--- Growing Income and Wealth ---
	, IIF(ROUND(income_12mo, 2) < 68120.00,1, NULL) AS below_med_income_12mo --Median individual weekly income * 52 for NZ March 2024 accross all age groups (StatsNZ Aotearoa Data Explorer)
	, IIF(ROUND(income_mother_12mo, 2) < 68120.00,1, NULL) AS below_med_income_mother_12mo
	, IIF(ROUND(income_father_12mo, 2) < 68120.00,1, NULL) AS below_med_income_father_12mo
	, IIF(ROUND(ws_income_12mo, 2) > 0,1, NULL) AS ws_income_12mo
	, IIF(ROUND(ws_income_mother_12mo, 2) > 0,1, NULL) AS ws_income_mother_12mo
	, IIF(ROUND(ws_income_father_12mo, 2) > 0,1, NULL) AS ws_income_father_12mo

--- Greater Safety ---
	, IIF(ace_score >= 4,1, NULL) AS ace_score_4_or_over
	, IIF(ot_report_concern_ever > 0,1, NULL) AS ot_report_concern_ever
	, IIF(ot_investigation_ever > 0,1, NULL) AS ot_investigation_ever
	, IIF(ot_fgc_ever > 0,1, NULL) AS ot_fgc_ever
	, IIF(ot_placement_ever > 0,ot_placement_ever, NULL) AS ot_placement_ever
	, IIF(ot_placement_12mo > 0,ot_placement_12mo, NULL) AS ot_placement_12mo
	, IIF(ot_report_concern_12mo > 0,1 ,NULL) as ot_report_concern_12mo
	, IIF(ot_investigation_12mo > 0,1, NULL) as ot_investigation_12mo
	, IIF(ot_fgc_12mo > 0,1, NULL) as ot_fgc_12mo
	, IIF(ot_findings_ever > 0,ot_findings_ever, NULL) AS ot_findings_ever
	, IIF(ot_findings_12mo > 0,ot_findings_12mo, NULL) AS ot_findings_12mo
	, IIF(crime_victimisations_12mo > 0,crime_victimisations_12mo, NULL) AS crime_victimisations_12mo
	, IIF(crime_victimisations_mother_12mo > 0,crime_victimisations_mother_12mo, NULL) AS crime_victimisations_mother_12mo
	, IIF(crime_victimisations_father_12mo > 0,crime_victimisations_father_12mo, NULL) AS crime_victimisations_father_12mo
	, IIF(violent_crime_victimisations_12mo > 0,violent_crime_victimisations_12mo, NULL) AS violent_crime_victimisations_12mo
	, IIF(violent_crime_victimisations_mother_12mo > 0,violent_crime_victimisations_mother_12mo, NULL) AS violent_crime_victimisations_mother_12mo
	, IIF(violent_crime_victimisations_father_12mo > 0,violent_crime_victimisations_father_12mo, NULL) AS violent_crime_victimisations_father_12mo
	, IIF(FVSV_victim_ever > 0,FVSV_victim_ever, NULL) AS FVSV_victim_ever
	, IIF(FVSV_victim_mother_ever > 0,FVSV_victim_mother_ever, NULL) AS FVSV_victim_mother_ever
	, IIF(FVSV_victim_father_ever > 0,FVSV_victim_father_ever, NULL) AS FVSV_victim_father_ever
	, IIF(FVSV_victim_12mo > 0,1, NULL) as FVSV_victim_12mo
	, IIF(FVSV_victim_mother_12mo > 0,1, NULL) as FVSV_victim_mother_12mo
	, IIF(FVSV_victim_father_12mo > 0,1, NULL) as FVSV_victim_father_12mo
	, IIF(offences_ever > 0,1, NULL) AS offences_ever
	, IIF(offences_12mo > 0,1, NULL) AS offences_12mo
	, IIF(youth_offences_ever > 0,1, NULL) AS youth_offences_ever
	, IIF(youth_offences_12mo > 0,1, NULL) AS youth_offences_12mo
	, IIF(alcohol_offences_12mo > 0,alcohol_offences_12mo, NULL) AS alcohol_offences_12mo
	, IIF(violent_offences_12mo > 0,violent_offences_12mo, NULL) AS violent_offences_12mo
	, IIF(non_violent_offences_12mo > 0,non_violent_offences_12mo, NULL) AS non_violent_offences_12mo
	, IIF(drug_offences_12mo > 0,drug_offences_12mo, NULL) AS drug_offences_12mo
	, IIF(alcohol_offences_mother_12mo > 0,alcohol_offences_mother_12mo, NULL) AS alcohol_offences_mother_12mo
	, IIF(violent_offences_mother_12mo > 0,violent_offences_mother_12mo, NULL) AS violent_offences_mother_12mo
	, IIF(non_violent_offences_mother_12mo > 0,non_violent_offences_mother_12mo, NULL) AS non_violent_offences_mother_12mo
	, IIF(drug_offences_mother_12mo > 0,drug_offences_mother_12mo, NULL) AS drug_offences_mother_12mo
	, IIF(alcohol_offences_father_12mo > 0,alcohol_offences_father_12mo, NULL) AS alcohol_offences_father_12mo
	, IIF(violent_offences_father_12mo > 0,violent_offences_father_12mo, NULL) AS violent_offences_father_12mo
	, IIF(non_violent_offences_father_12mo > 0,non_violent_offences_father_12mo, NULL) AS non_violent_offences_father_12mo
	, IIF(drug_offences_father_12mo > 0,drug_offences_father_12mo, NULL) AS drug_offences_father_12mo
	, IIF(police_interactions_any_12mo > 0,police_interactions_any_12mo, NULL) AS police_interactions_any_12mo
	, IIF(police_interactions_any_mother_12mo > 0,police_interactions_any_mother_12mo, NULL) AS police_interactions_any_mother_12mo
	, IIF(police_interactions_any_father_12mo > 0,police_interactions_any_father_12mo, NULL) AS police_interactions_any_father_12mo
	, IIF(court_charges_ever > 0,court_charges_ever, NULL) AS court_charges_ever
	, IIF(court_charges_mother_ever > 0,court_charges_mother_ever, NULL) AS court_charges_mother_ever
	, IIF(court_charges_father_ever > 0,court_charges_father_ever, NULL) AS court_charges_father_ever
	, IIF(court_charges_12mo > 0,1 ,NULL) as court_charges_12mo
	, IIF(court_charges_mother_12mo > 0,1 ,NULL) as court_charges_mother_12mo
	, IIF(court_charges_father_12mo > 0,1 ,NULL) as court_charges_father_12mo
	, IIF(corr_any_12mo > 0,corr_any_12mo, NULL) AS corr_any_12mo
	, IIF(corr_any_mother_12mo > 0,corr_any_mother_12mo, NULL) AS corr_any_mother_12mo
	, IIF(corr_any_father_12mo > 0,corr_any_father_12mo, NULL) AS corr_any_father_12mo
	, IIF(corr_incarcerated_ever > 0,corr_incarcerated_ever, NULL) AS corr_incarcerated_ever
	, IIF(corr_incarcerated_mother_ever > 0,corr_incarcerated_mother_ever, NULL) AS corr_incarcerated_mother_ever
	, IIF(corr_incarcerated_father_ever > 0,corr_incarcerated_father_ever, NULL) AS corr_incarcerated_father_ever
	, IIF(corr_incarcerated_12mo > 0,1, NULL) as corr_incarcerated_12mo
	, IIF(corr_incarcerated_mother_12mo > 0,1, NULL) as corr_incarcerated_mother_12mo
	, IIF(corr_incarcerated_father_12mo > 0,1, NULL) as corr_incarcerated_father_12mo
	, IIF(yj_fgc_ever > 0,1, NULL) AS yj_fgc_ever
	, IIF(yj_placement_ever > 0,1, NULL) AS yj_placement_ever
	, IIF(yj_fgc_12mo > 0,1,NULL) as yj_fgc_12mo
	, IIF(yj_placement_12mo > 0,1,NULL) as yj_placement_12mo

--- Ensuring secure and stable housing ---
	, IIF(hnz_waitlist_12mo > 0,hnz_waitlist_12mo, NULL) AS hnz_waitlist_12mo
	, IIF(hnz_waitlist_mother_12mo > 0,hnz_waitlist_mother_12mo, NULL) AS hnz_waitlist_mother_12mo
	, IIF(hnz_waitlist_father_12mo> 0,hnz_waitlist_father_12mo, NULL) AS hnz_waitlist_father_12mo
	, IIF(social_housing_12mo > 0,social_housing_12mo, NULL) AS social_housing_12mo
	, IIF(social_housing_mother_12mo > 0,social_housing_mother_12mo, NULL) AS social_housing_mother_12mo
	, IIF(social_housing_father_12mo> 0,social_housing_father_12mo, NULL) AS social_housing_father_12mo
	, IIF(emergency_housing_12mo > 0,emergency_housing_12mo, NULL) AS emergency_housing_12mo
	, IIF(emergency_housing_mother_12mo > 0,emergency_housing_mother_12mo, NULL) AS emergency_housing_mother_12mo
	, IIF(emergency_housing_father_12mo > 0,emergency_housing_father_12mo, NULL) AS emergency_housing_father_12mo

--- Improving Knowledge and Skills ---
	, IIF(highest_qual_current > 0,1, NULL) AS highest_qual_current
	, highest_qual_entity__min
	, highest_qual_entity__max
	, IIF(highest_qual_mother_current > 0,1, NULL) AS highest_qual_mother_current
	, highest_qual_entity_mother__min
	, highest_qual_entity_mother__max
	, IIF(highest_qual_father_current > 0,1, NULL) AS highest_qual_father_current
	, highest_qual_entity_father__min
	, highest_qual_entity_father__max
	, IIF(tert_study_current > 0,tert_study_current, NULL) AS tert_study_current
	, tertiary_entity__min
	, tertiary_entity__max
	, IIF(school_enrol_current > 0,school_enrol_current, NULL) AS school_enrol_current
	, school_entity__min
	, school_entity__max
	, IIF(school_attendance_12mo = 'Regular attendance',1, NULL) AS regular_attendance_12mo
	, IIF(school_attendance_12mo = 'Chronic Absence',1, NULL) AS chronic_absence_12mo
	, school_attendance_entity__min
	, school_attendance_entity__max
	, IIF(SSEE_exclude_expel_ever > 0,SSEE_exclude_expel_ever, NULL) AS SSEE_exclude_expel_ever
	, IIF(SSEE_suspended_ever > 0,SSEE_suspended_ever, NULL) AS SSEE_suspended_ever
	, IIF(SSEE_standdown_ever > 0,1, NULL) AS SSEE_standdown_ever
	, SSEE_entity_ever__min
	, SSEE_entity_ever__max
	, IIF(SSEE_exclude_expel_12mo > 0,1, NULL) as SSEE_exclude_expel_12mo
	, IIF(SSEE_suspended_12mo > 0,1, NULL) as SSEE_suspended_12mo
	, IIF(SSEE_standdown_12mo > 0,1, NULL) as SSEE_standdown_12mo
	, SSEE_entity_12mo__min
	, SSEE_entity_12mo__max
	, IIF(learning_support_ever > 0,1, NULL) AS learning_support_ever
	, learning_support_entity_ever__min
	, learning_support_entity_ever__max
	, IIF(learning_support_12mo > 0,1, NULL) as learning_support_12mo
	, learning_support_entity_12mo__min
	, learning_support_entity_12mo__max
	, IIF(alt_ed_ever > 0,alt_ed_ever, NULL) AS alt_ed_ever
	, alt_ed_entity_ever__min
	, alt_ed_entity_ever__max
	, IIF(alt_ed_12mo > 0,1,NULL) as alt_ed_12mo
	, alt_ed_entity_12mo__min
	, alt_ed_entity_12mo__max
	, IIF(attendance_service_ever > 0,attendance_service_ever, NULL) AS attendance_service_ever
	, attendance_service_entity_ever__min
	, attendance_service_entity_ever__max
	, IIF(attendance_service_12mo > 0,1, NULL) as attendance_service_12mo
	, attendance_service_entity_12mo__min
	, attendance_service_entity_12mo__max
	, IIF(ece_any_attend_12mo > 0,ece_any_attend_12mo, NULL) AS ece_any_attend_12mo
	, IIF(ece_duration_minutes/60/38.5 >=20,1, NULL) AS ece_20hr_plus  --based on ~385 half days per year, number of weeks is 38.5
	, ece_entity__min
	, ece_entity__max
	, IIF(school_changes_nonstructural_ever >=2,1, NULL) AS two_or_more_school_changes_nonstructural_ever
	, IIF(school_changes_nonstructural_12mo >= 2,1, NULL) as two_or_more_school_changes_nonstructural_12mo

--- Priority cohort membership---
	, IIF(cohort_member_CEP > 0,cohort_member_CEP, NULL) AS cohort_member_CEP
	, IIF(cohort_member_CIP > 0,cohort_member_CIP, NULL) AS cohort_member_CIP
	, IIF(cohort_member_SSEE > 0,cohort_member_SSEE, NULL) AS cohort_member_SSEE
	, cohort_member_SSEE_entity__min
	, cohort_member_SSEE_entity__max
	, IIF(cohort_member_maternal_aod_child > 0, cohort_member_maternal_aod_child, NULL) AS cohort_member_maternal_aod_child
	, IIF(cohort_member_maternal_aod_mother > 0, cohort_member_maternal_aod_mother, NULL) AS cohort_member_maternal_aod_mother

--- Max dates ---

	, max_date_CM_msd_ise_main_benefit_date
	, max_date_IRD_ems_date
	, max_date_NEET_date
	, max_date_CM_nzta_driver_licences_status_date
	, max_date_MOH_public_hospital_event_date
	, max_date_MOH_pharmaceutical_date
	, max_date_MOH_nes_enrolment_date
	, max_date_ACC_claims_date
	, max_date_MOH_primhd_date
	, max_date_MOH_nnpac_date
	, max_date_CM_income_t2_total_income_date
	, max_date_CYF_investigations_date
	, max_date_CYF_fgc_date
	, max_date_CYF_placements_date
	, max_date_POL_pre_count_victims_date
	, max_date_CM_family_sexual_violence_date
	, max_date_POL_pre_count_offenders_date
	, max_date_POL_nia_links_date
	, max_date_MOJ_charges_date
	, max_date_COR_management_date
	, max_date_HNZ_tenancy_hhld_snapshot_date
	, max_date_MSD_T3_expenditure_date
	, max_date_CM_highest_nqflevel_spells_date
	, max_date_MOE_enrolment_date
	, max_date_MOE_student_enrol_date
	, max_date_CM_moe_sch_att_year_date
	, max_date_MOE_student_interventions_date
	, max_date_MOE_ECE_date
	, max_date_CM_sh_waitlist_spells_date
	, max_date_CM_OT_findings_date
	, max_date_MOH_immunisations_date
	, max_date_MOH_B4SC_date
	, max_date_CM_msd_ise_adhoc_date
	 
FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_current_state_master_table_202603]
GO
