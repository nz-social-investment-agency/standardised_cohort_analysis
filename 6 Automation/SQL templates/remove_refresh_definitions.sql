/******************************************************************************
Clean up definitions from refresh

This script is used to remove tables for a refresh, in order to keep UserCode
 and the Sandpit clean and tidy. It should be run manually when removing the
 refresh - including it in a pipeline risks accidentally dropping tables.

This script lists all the tables / views, labeled by the file in which they
 are created. It does not include cohort-specific tables.

History:
2026-04-10 SA initial version based on DY design
2026-02-04 DY Created initial version
******************************************************************************/

USE IDI_UserCode
GO

-- address_and_geographies
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_address_higher_geog_{REFRESH}]
-- alternative_education
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_alternative_education_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_alternative_education_merged_{REFRESH}]
-- any_corrections_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_corrections_any_{REFRESH}]
-- attendance_service_support
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_attendance_service_support_{REFRESH}] 
-- avoidable hospitalisations
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_ASH_PAH_{REFRESH}]
-- B4SC_SDQ_PEDS
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_B4SC_SDQ_PEDS_{REFRESH}]
-- child_parent_caregiver
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_child_parent_{REFRESH}]
-- chronic_diabetes
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_chronic_diabetes_{REFRESH}]
-- CM_autism
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_autism_{REFRESH}]
-- cohort_cep
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[cohort_CEP_{REFRESH}]
-- cohort_CIP_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[cohort_CIP_spells_{REFRESH}]
-- cohort_maternal_alc_drug
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[mother_child_w_aod_flag_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[cohort_maternal_aod_{REFRESH}]
-- cohort_ssee
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[cohort_SSEE_{REFRESH}]
-- conventional_ACEs
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_conventional_ACE_scores_{REFRESH}]
-- ECE_attendance
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_ECE_attendance_{REFRESH}]
-- educational_disengagement
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_education_disengagement_{REFRESH}]
-- emergency_department_visits
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_emergency_department_{REFRESH}]
-- emergency_housing_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_emergency_housing_{REFRESH}]
-- employment_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_employed_spell_staging_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_employed_spell_{REFRESH}]
-- Generalised_ACE scores
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_generalised_ACE_scores_{REFRESH}]
-- hospitalisations
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_hospitalisations_{REFRESH}]
-- learning_supports
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_learning_supports_{REFRESH}]
-- level_1_and_2_ethnicity
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_ethnicity_level_2_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_ethnicity_level_1_and_2_{REFRESH}]
-- max_date ACC claims
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_ACC_claims_{REFRESH}]
-- max_date B4SC
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_B4SC_{REFRESH}]
-- max_date CM family_sexual_violence
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_family_sexual_violence_{REFRESH}]
-- max_date CM highest_nqflevel_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_highest_nqflevel_spells_{REFRESH}]
-- max_date CM income_t2_total_income
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[max_date_CM_income_t2_total_income_{REFRESH}]
-- max_date CM moe_sch_att_year
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_moe_sch_att_year_{REFRESH}]
-- max_date CM msd_ise_main_benefit
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[max_date_CM_msd_ise_main_benefit_{REFRESH}]
-- max_date CM nzta_driver_licences_status
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_nzta_driver_licences_status_{REFRESH}]
-- max_date CM OT_findings
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_OT_findings_{REFRESH}]
-- max_date CM sh_waitlist_spells
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CM_sh_waitlist_spells_{REFRESH}]
-- max_date COR management
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_COR_management_{REFRESH}]
-- max_date CYF fgc
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CYF_fgc_{REFRESH}]
-- max_date CYF investigations
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CYF_investigations_{REFRESH}]
-- max_date CYF placements
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CYF_placements_{REFRESH}]
-- max_date CYF roc
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_CYF_roc_{REFRESH}]
-- max_date ECE attendance
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_ECE_attendance_{REFRESH}]
-- max_date HNZ tenancy_hhld_snapshot
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_HNZ_tenancy_household_snapshot_{REFRESH}]
-- max_date IRD ems
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_IRD_ems_{REFRESH}]
-- max_date MOE enrolment
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOE_enrolment_{REFRESH}]
-- max_date MOE student_enrol
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOE_student_enrol_{REFRESH}]
-- max_date MOE student_interventions
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOE_student_interventions_{REFRESH}]
-- max_date MOE tec_it_learner
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOE_tec_it_learner_{REFRESH}]
-- max_date MOH avoid hospital
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_avoid_hosp_{REFRESH}]
-- max_date MOH immunisations
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_immunisations_{REFRESH}]
-- max_date MOH nes_enrolment
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_nes_enrolment_{REFRESH}]
-- max_date MOH nnpac
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_nnpac_{REFRESH}]
-- max_date MOH pharmaceutical
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_pharmaceutical_{REFRESH}]
-- max_date MOH primhd
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_primhd_{REFRESH}]
-- max_date MOH private_hospital_event
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_priv_fund_hosp_discharges_event_{REFRESH}]
-- max_date MOH public_hospital_event
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOH_pub_fund_hosp_discharges_event_{REFRESH}]
-- max_date MOJ charges
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MOJ_charges_{REFRESH}]
-- max_date MSD T3_expenditure
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_MSD_msd_third_tier_expenditure_{REFRESH}]
-- max_date NEET
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_NEET_{REFRESH}]
-- max_date POL nia_links
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_POL_nia_links_{REFRESH}]
-- max_date POL pre_count_offenders
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_POL_pre_count_offenders_{REFRESH}]
-- max_date POL pre_count_victims
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_POL_pre_count_victimisations_{REFRESH}]
-- max_date SNZ address_notification
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_SNZ_address_notification_{REFRESH}]
-- max_date SNZ person_overseas_spell
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[max_date_SNZ_person_overseas_spell_{REFRESH}]
-- mha_alcohol_abuse_dependence
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_alcohol_abuse_or_dependence_{REFRESH}]
-- mha_bipolar
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_bipolar_{REFRESH}]
-- MHA_combined
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_substance_abuse_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_mental_illness_{REFRESH}]
-- mha_drug_abuse_dependance
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_drug_abuse_or_dependence_{REFRESH}]
-- mha_dysthymia
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_dysthymia_{REFRESH}]
-- mha_generalised_anxiety_disorder
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_generalised_anxiety_disorder_{REFRESH}]
-- mha_major_depressive_disorder
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_major_depressive_disorder_{REFRESH}]
-- mha_schizophrenia
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_mha_schizophrenia_{REFRESH}]
-- mha_service
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_MHA_service_use_{REFRESH}]
-- NEET
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_neet_spells_{REFRESH}]
-- non_structural_school_moves
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_school_changes_{REFRESH}]
-- OT_interactions
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_OT_interactions_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_OT_custody_{REFRESH}]
-- parental_seperation
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_separation_{REFRESH}]
-- parents_with_child_birthdates
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_child_birthdates_{REFRESH}]
-- pharmaceutical_dispensing
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_pharma_dispensing_{REFRESH}]
-- PHO_enrolment
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_pho_enrollment_{REFRESH}]
-- police_categorised_interactions
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_police_offence_categorised_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_police_victim_categorised_{REFRESH}]
-- school_enrolled
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_school_enrolled_{REFRESH}]
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_school_enrolled_no_overlaps_{REFRESH}]
-- social_housing_by_tenancy
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_hnz_tenancy_{REFRESH}]
-- SSEE_w_flags
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_SSEE_w_flag_{REFRESH}]
-- tertiary_enrolment
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_tertiary_enrol_{REFRESH}]
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_any_tertiary_study_{REFRESH}]
-- transient_students
DROP VIEW IF EXISTS [{PROJECT_SCHEMA}].[defn_transient_students_{REFRESH}]
-- YORST definition
DROP TABLE IF EXISTS [{PROJECT_DB}].[{PROJECT_SCHEMA}].[defn_yorst_score_at_police_proceeding_{REFRESH}]
