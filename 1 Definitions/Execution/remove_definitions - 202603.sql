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
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_address_higher_geog_202603]
-- alternative_education
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_alternative_education_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_alternative_education_merged_202603]
-- any_corrections_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_corrections_any_202603]
-- attendance_service_support
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_attendance_service_support_202603] 
-- avoidable hospitalisations
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_ASH_PAH_202603]
-- B4SC_SDQ_PEDS
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_B4SC_SDQ_PEDS_202603]
-- child_parent_caregiver
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_child_parent_202603]
-- chronic_diabetes
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_chronic_diabetes_202603]
-- CM_autism
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_autism_202603]
-- cohort_cep
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[cohort_CEP_202603]
-- cohort_CIP_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[cohort_CIP_spells_202603]
-- cohort_maternal_alc_drug
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[mother_child_w_aod_flag_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[cohort_maternal_aod_202603]
-- cohort_ssee
DROP VIEW IF EXISTS [DL-MAA2026-04].[cohort_SSEE_202603]
-- conventional_ACEs
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_conventional_ACE_scores_202603]
-- ECE_attendance
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_ECE_attendance_202603]
-- educational_disengagement
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_education_disengagement_202603]
-- emergency_department_visits
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_emergency_department_202603]
-- emergency_housing_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_emergency_housing_202603]
-- employment_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_employed_spell_staging_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_employed_spell_202603]
-- Generalised_ACE scores
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_generalised_ACE_scores_202603]
-- hospitalisations
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_hospitalisations_202603]
-- learning_supports
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_learning_supports_202603]
-- level_1_and_2_ethnicity
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_ethnicity_level_2_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_ethnicity_level_1_and_2_202603]
-- max_date ACC claims
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_ACC_claims_202603]
-- max_date B4SC
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_B4SC_202603]
-- max_date CM family_sexual_violence
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_family_sexual_violence_202603]
-- max_date CM highest_nqflevel_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_highest_nqflevel_spells_202603]
-- max_date CM income_t2_total_income
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[max_date_CM_income_t2_total_income_202603]
-- max_date CM moe_sch_att_year
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_moe_sch_att_year_202603]
-- max_date CM msd_ise_main_benefit
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[max_date_CM_msd_ise_main_benefit_202603]
-- max_date CM nzta_driver_licences_status
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_nzta_driver_licences_status_202603]
-- max_date CM OT_findings
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_OT_findings_202603]
-- max_date CM sh_waitlist_spells
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CM_sh_waitlist_spells_202603]
-- max_date COR management
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_COR_management_202603]
-- max_date CYF fgc
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CYF_fgc_202603]
-- max_date CYF investigations
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CYF_investigations_202603]
-- max_date CYF placements
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CYF_placements_202603]
-- max_date CYF roc
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_CYF_roc_202603]
-- max_date ECE attendance
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_ECE_attendance_202603]
-- max_date HNZ tenancy_hhld_snapshot
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_HNZ_tenancy_household_snapshot_202603]
-- max_date IRD ems
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_IRD_ems_202603]
-- max_date MOE enrolment
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOE_enrolment_202603]
-- max_date MOE student_enrol
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOE_student_enrol_202603]
-- max_date MOE student_interventions
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOE_student_interventions_202603]
-- max_date MOE tec_it_learner
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOE_tec_it_learner_202603]
-- max_date MOH avoid hospital
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_avoid_hosp_202603]
-- max_date MOH immunisations
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_immunisations_202603]
-- max_date MOH nes_enrolment
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_nes_enrolment_202603]
-- max_date MOH nnpac
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_nnpac_202603]
-- max_date MOH pharmaceutical
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_pharmaceutical_202603]
-- max_date MOH primhd
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_primhd_202603]
-- max_date MOH private_hospital_event
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_priv_fund_hosp_discharges_event_202603]
-- max_date MOH public_hospital_event
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOH_pub_fund_hosp_discharges_event_202603]
-- max_date MOJ charges
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MOJ_charges_202603]
-- max_date MSD T3_expenditure
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_MSD_msd_third_tier_expenditure_202603]
-- max_date NEET
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_NEET_202603]
-- max_date POL nia_links
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_POL_nia_links_202603]
-- max_date POL pre_count_offenders
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_POL_pre_count_offenders_202603]
-- max_date POL pre_count_victims
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_POL_pre_count_victimisations_202603]
-- max_date SNZ address_notification
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_SNZ_address_notification_202603]
-- max_date SNZ person_overseas_spell
DROP VIEW IF EXISTS [DL-MAA2026-04].[max_date_SNZ_person_overseas_spell_202603]
-- mha_alcohol_abuse_dependence
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_alcohol_abuse_or_dependence_202603]
-- mha_bipolar
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_bipolar_202603]
-- MHA_combined
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_substance_abuse_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_mental_illness_202603]
-- mha_drug_abuse_dependance
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_drug_abuse_or_dependence_202603]
-- mha_dysthymia
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_dysthymia_202603]
-- mha_generalised_anxiety_disorder
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_generalised_anxiety_disorder_202603]
-- mha_major_depressive_disorder
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_major_depressive_disorder_202603]
-- mha_schizophrenia
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_mha_schizophrenia_202603]
-- mha_service
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_MHA_service_use_202603]
-- NEET
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_neet_spells_202603]
-- non_structural_school_moves
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_school_changes_202603]
-- OT_interactions
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_OT_interactions_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_OT_custody_202603]
-- parental_seperation
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_separation_202603]
-- parents_with_child_birthdates
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_child_birthdates_202603]
-- pharmaceutical_dispensing
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_pharma_dispensing_202603]
-- PHO_enrolment
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_pho_enrollment_202603]
-- police_categorised_interactions
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_police_offence_categorised_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_police_victim_categorised_202603]
-- school_enrolled
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_school_enrolled_202603]
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_school_enrolled_no_overlaps_202603]
-- social_housing_by_tenancy
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_hnz_tenancy_202603]
-- SSEE_w_flags
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_SSEE_w_flag_202603]
-- tertiary_enrolment
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_tertiary_enrol_202603]
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_any_tertiary_study_202603]
-- transient_students
DROP VIEW IF EXISTS [DL-MAA2026-04].[defn_transient_students_202603]
-- YORST definition
DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[defn_yorst_score_at_police_proceeding_202603]
