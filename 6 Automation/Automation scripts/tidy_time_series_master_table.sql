/**************************************************************************************************
Title: Tidy master table for time series analysis
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
Output
- [IDI_UserCode].[DL-MAA2023-46].[$COHORT_time_series_master_table]

Intended purpose:
Tidy the master table that will be used for time series results.

Notes:

Parameters & Present values:
	Project schema = [DL-MAA2023-46]
	Cohort term for injection = $COHORT

Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [DL-MAA2023-46].[$COHORT_time_series_master_table]
GO

CREATE VIEW [DL-MAA2023-46].[$COHORT_time_series_master_table] 
AS
SELECT snz_uid
	, period_start
	, period_end
	, [period]

--- Entity counts for cohort (in case required) ----
	,entity_cohort_mha
	,entity_cohort_edu
	,entity_cohort_pbn
	,entity_cohort_ent

	, DATEDIFF(DAY, period_start, period_end) AS duration
	, organisation
	, client_status
	, dob
	, eth_european
	, eth_maori
	, eth_pacific
	, eth_asian
	, eth_MELAA
	, eth_other
	, sex
	, REGC
	, TALB
	, REGC_NAME
	, TALB_NAME
	, NZDep
	, disability
	, IIF([WS_income_period_dollars] = 0, NULL, [WS_income_period_dollars]) AS [WS_income_period_dollars]
	, IIF([income_period_dollars] = 0, NULL, [income_period_dollars]) AS [income_period_dollars]
	, IIF([corr_any_cnt] = 0, NULL, [corr_any_cnt]) AS [corr_any_cnt]
	, IIF([corr_incarcerated_cnt] = 0, NULL, [corr_incarcerated_cnt]) AS [corr_incarcerated_cnt]
	, IIF([ot_investigation_cnt] = 0, NULL, [ot_investigation_cnt]) AS [ot_investigation_cnt]
	, IIF([ot_fgc_cnt] = 0, NULL, [ot_fgc_cnt]) AS [ot_fgc_cnt]
	, IIF([ot_placement_cnt] = 0, NULL, [ot_placement_cnt]) AS [ot_placement_cnt]
	, IIF([ot_report_concern_cnt] = 0, NULL, [ot_report_concern_cnt]) AS [ot_report_concern_cnt]
	, IIF([yj_fgc_cnt] = 0, NULL, [yj_fgc_cnt]) AS [yj_fgc_cnt]
	, IIF([yj_placement_cnt] = 0, NULL, [yj_placement_cnt]) AS [yj_placement_cnt]
	, IIF([highest_qual] = 0, NULL, [highest_qual]) AS [highest_qual]
	, highest_qual_entity__min
	, highest_qual_entity__max
	, IIF([FVSV_user_cnt] = 0, NULL, [FVSV_user_cnt]) AS [FVSV_user_cnt]
	, IIF([FVSV_victim_cnt] = 0, NULL, [FVSV_victim_cnt]) AS [FVSV_victim_cnt]
	, IIF([acc_injuries_cnt] = 0, NULL, [acc_injuries_cnt]) AS [acc_injuries_cnt]
	, IIF([court_charges_cnt] = 0, NULL, [court_charges_cnt]) AS [court_charges_cnt]
	, IIF([MHA_service_cnt] = 0, NULL, [MHA_service_cnt]) AS [MHA_service_cnt]
	, MHA_entity__min
	, MHA_entity__max
	, IIF([social_housing_days] = 0, NULL, [social_housing_days]) AS [social_housing_days]
	, IIF([emergency_housing_days] = 0, NULL, [emergency_housing_days]) AS [emergency_housing_days]
	, IIF([ED_visits_cnt] = 0, NULL, [ED_visits_cnt]) AS [ED_visits_cnt]
	, IIF([Hospitalisations_cnt] = 0, NULL, [Hospitalisations_cnt]) AS [Hospitalisations_cnt]
	, IIF([time_in_hospital_days] = 0, NULL, [time_in_hospital_days]) AS [time_in_hospital_days]
	, IIF([avoid_hosp_cnt] = 0, NULL, [avoid_hosp_cnt]) AS [avoid_hosp_cnt]
	, IIF([main_benefit_duration_days] = 0, NULL, [main_benefit_duration_days]) AS [main_benefit_duration_days]
	, IIF([JSWR_duration_days] = 0, NULL, [JSWR_duration_days]) AS [JSWR_duration_days]
	, IIF([SPS_duration_days] = 0, NULL, [SPS_duration_days]) AS [SPS_duration_days]
	, IIF([school_enrol_days] = 0, NULL, [school_enrol_days]) AS [school_enrol_days]
	, school_entity__min
	, school_entity__max
	, IIF([tert_study_any_days] = 0, NULL, [tert_study_any_days]) AS [tert_study_any_days]
	, tertiary_entity__min
	, tertiary_entity__max
	, IIF([employed_duration_days] = 0, NULL, [employed_duration_days]) AS [employed_duration_days]
	, pbn_entity__min
	, pbn_entity__max
	, enterprise_entity__min
	, enterprise_entity__max
	, IIF([neet_duration_days] = 0, NULL, [neet_duration_days]) AS [neet_duration_days]
	, IIF([pharmaceutical_dispensing_cnt] = 0, NULL, [pharmaceutical_dispensing_cnt]) AS [pharmaceutical_dispensing_cnt]
	, IIF([crime_victimisations_cnt] = 0, NULL, [crime_victimisations_cnt]) AS [crime_victimisations_cnt]
	, IIF([police_interactions_any_cnt] = 0, NULL, [police_interactions_any_cnt]) AS [police_interactions_any_cnt]
	, IIF([offences_alcohol_cnt] = 0, NULL, [offences_alcohol_cnt]) AS [offences_alcohol_cnt]
	, IIF([offences_violent_cnt] = 0, NULL, [offences_violent_cnt]) AS [offences_violent_cnt]
	, IIF([offences_non_violent_cnt] = 0, NULL, [offences_non_violent_cnt]) AS [offences_non_violent_cnt]
	, IIF([offences_drug_cnt] = 0, NULL, [offences_drug_cnt]) AS [offences_drug_cnt]
	, IIF([SSEE_cnt] = 0, NULL, [SSEE_cnt]) AS [SSEE_cnt]
	, SSEE_entity__min
	, SSEE_entity__max
	, IIF([alt_ed_cnt] = 0, NULL, [alt_ed_cnt]) AS [alt_ed_cnt]
	, alt_ed_entity__min
	, alt_ed_entity__max
	, IIF([attendance_service_days] = 0, NULL, [attendance_service_days]) AS [attendance_service_days]
	, attendance_service_entity__min
	, attendance_service_entity__max
	, IIF([learning_support_cnt] = 0, NULL, [learning_support_cnt]) AS [learning_support_cnt]
	, learning_support_entity__min
	, learning_support_entity__max

	/* max_date durations */
	, max_date_ACC_claims
	, max_date_COR_management
	, max_date_CYF_fgc
	, max_date_CYF_investigations
	, max_date_CYF_placements
	, max_date_SNZ_address_notification
	, max_date_HNZ_tenancy_hhld_snapshot
	, max_date_IRD_ems
	, max_date_MOE_enrolment
	, max_date_MOE_student_enrol
	, max_date_MOE_student_interventions
	, max_date_MOE_tec_it_learner
	, max_date_MOH_nnpac
	, max_date_MOH_pharmaceutical
	, max_date_MOH_primhd
	, max_date_MOH_public_hospital_event
	, max_date_MOJ_charges
	, max_date_MSD_T3_expenditure
	, max_date_POL_nia_links
	, max_date_POL_pre_count_offenders
	, max_date_POL_pre_count_victims
	, max_date_CM_family_sexual_violence
	, max_date_CM_highest_nqflevel_spells
	, max_date_CM_income_t2_total_income
	, max_date_CM_msd_ise_main_benefit
	, max_date_NEET
	, max_date_CYF_roc
	, max_date_avoid_hosp

	/* max_date dates */
	, max_date_ACC_claims_date
	, max_date_COR_management_date
	, max_date_CYF_fgc_date
	, max_date_CYF_investigations_date
	, max_date_CYF_placements_date
	, max_date_SNZ_address_notification_date
	, max_date_HNZ_tenancy_hhld_snapshot_date
	, max_date_IRD_ems_date
	, max_date_MOE_enrolment_date
	, max_date_MOE_student_enrol_date
	, max_date_MOE_student_interventions_date
	, max_date_MOE_tec_it_learner_date
	, max_date_MOH_nnpac_date
	, max_date_MOH_pharmaceutical_date
	, max_date_MOH_primhd_date
	, max_date_MOH_public_hospital_event_date
	, max_date_MOJ_charges_date
	, max_date_MSD_T3_expenditure_date
	, max_date_POL_nia_links_date
	, max_date_POL_pre_count_offenders_date
	, max_date_POL_pre_count_victims_date
	, max_date_CM_family_sexual_violence_date
	, max_date_CM_highest_nqflevel_spells_date
	, max_date_CM_income_t2_total_income_date
	, max_date_CM_msd_ise_main_benefit_date
	, max_date_NEET_date
	, max_date_CYF_roc_date
	, max_date_avoid_hosp_date

	/* annualised amounts per year */
	,IIF(max_date_ACC_claims > 30				, 365.0 * COALESCE(acc_injuries_cnt, 0) 				/ max_date_ACC_claims, NULL)				AS ratio_acc_injuries_cnt
	,IIF(max_date_POL_pre_count_offenders > 30	, 365.0 * COALESCE(offences_alcohol_cnt, 0) 			/ max_date_POL_pre_count_offenders, NULL)	AS ratio_offences_alcohol_cnt
	,IIF(max_date_COR_management > 30			, 365.0 * COALESCE(corr_any_cnt, 0) 					/ max_date_COR_management, NULL)			AS ratio_corr_any_cnt
	,IIF(max_date_COR_management > 30			, 365.0 * COALESCE(corr_incarcerated_cnt, 0) 			/ max_date_COR_management, NULL)			AS ratio_corr_incarcerated_cnt
	,IIF(max_date_MOJ_charges > 30				, 365.0 * COALESCE(court_charges_cnt, 0) 				/ max_date_MOJ_charges, NULL)				AS ratio_court_charges_cnt
	,IIF(max_date_POL_pre_count_victims > 30	, 365.0 * COALESCE(crime_victimisations_cnt, 0) 		/ max_date_POL_pre_count_victims, NULL)		AS ratio_crime_victimisations_cnt
	,IIF(max_date_POL_pre_count_offenders > 30	, 365.0 * COALESCE(offences_drug_cnt, 0) 				/ max_date_POL_pre_count_offenders, NULL)	AS ratio_offences_drug_cnt
	,IIF(max_date_MOH_nnpac > 30				, 365.0 * COALESCE(ED_visits_cnt, 0) 					/ max_date_MOH_nnpac, NULL)					AS ratio_ED_visits_cnt
	,IIF(max_date_MSD_T3_expenditure > 30		, 365.0 * COALESCE(emergency_housing_days, 0) 			/ max_date_MSD_T3_expenditure, NULL)		AS ratio_emergency_housing_days
	,IIF(max_date_IRD_ems > 30					, 365.0 * COALESCE(employed_duration_days, 0) 			/ max_date_IRD_ems, NULL)					AS ratio_employed_duration_days
	,IIF(max_date_CM_family_sexual_violence > 30, 365.0 * COALESCE(FVSV_user_cnt, 0) 					/ max_date_CM_family_sexual_violence, NULL) AS ratio_FVSV_user_cnt
	,IIF(max_date_CM_family_sexual_violence > 30, 365.0 * COALESCE(FVSV_victim_cnt, 0) 					/ max_date_CM_family_sexual_violence, NULL) AS ratio_FVSV_victim_cnt
	,IIF(max_date_MOH_public_hospital_event > 30, 365.0 * COALESCE(Hospitalisations_cnt, 0) 			/ max_date_MOH_public_hospital_event, NULL) AS ratio_Hospitalisations_cnt
	,IIF(max_date_IRD_ems > 30					, 365.0 * COALESCE(income_period_dollars, 0) 			/ max_date_IRD_ems, NULL)					AS ratio_income_period_dollars
	,IIF(max_date_CM_msd_ise_main_benefit > 30	, 365.0 * COALESCE(main_benefit_duration_days, 0)		/ max_date_CM_msd_ise_main_benefit, NULL)	AS ratio_main_benefit_duration_days
	,IIF(max_date_CM_msd_ise_main_benefit > 30	, 365.0 * COALESCE(JSWR_duration_days, 0)				/ max_date_CM_msd_ise_main_benefit, NULL)	AS ratio_JSWR_duration_days
	,IIF(max_date_CM_msd_ise_main_benefit > 30	, 365.0 * COALESCE(SPS_duration_days, 0)				/ max_date_CM_msd_ise_main_benefit, NULL)	AS ratio_SPS_duration_days
	,IIF(max_date_MOH_primhd > 30				, 365.0 * COALESCE(MHA_service_cnt, 0)					/ max_date_MOH_primhd, NULL)				AS ratio_MHA_service_cnt
	,IIF(max_date_NEET > 30						, 365.0 * COALESCE(neet_duration_days, 0)				/ max_date_NEET, NULL)						AS ratio_neet_duration_days
	,IIF(max_date_POL_pre_count_offenders > 30	, 365.0 * COALESCE(offences_non_violent_cnt, 0)			/ max_date_POL_pre_count_offenders, NULL)	AS ratio_offences_non_violent_cnt
	,IIF(max_date_CYF_fgc > 30					, 365.0 * COALESCE(ot_fgc_cnt, 0)						/ max_date_CYF_fgc, NULL)					AS ratio_ot_fgc_cnt
	,IIF(max_date_CYF_investigations > 30		, 365.0 * COALESCE(ot_investigation_cnt, 0)				/ max_date_CYF_investigations, NULL)		AS ratio_ot_investigation_cnt
	,IIF(max_date_CYF_placements > 30			, 365.0 * COALESCE(ot_placement_cnt, 0)					/ max_date_CYF_placements, NULL)			AS ratio_ot_placement_cnt
	,IIF(max_date_MOH_pharmaceutical > 30		, 365.0 * COALESCE(pharmaceutical_dispensing_cnt, 0)	/ max_date_MOH_pharmaceutical, NULL)		AS ratio_pharmaceutical_dispensing_cnt
	,IIF(max_date_POL_nia_links > 30			, 365.0 * COALESCE(police_interactions_any_cnt, 0)		/ max_date_POL_nia_links, NULL)				AS ratio_police_interactions_any_cnt
	,IIF(max_date_MOE_student_enrol > 30		, 365.0 * COALESCE(school_enrol_days, 0)				/ max_date_MOE_student_enrol, NULL)			AS ratio_school_enrol_days
	,IIF(max_date_HNZ_tenancy_hhld_snapshot > 30, 365.0 * COALESCE(social_housing_days, 0) 				/ max_date_HNZ_tenancy_hhld_snapshot, NULL) AS ratio_social_housing_days
	,IIF(max_date_MOE_student_interventions > 30, 365.0 * COALESCE(SSEE_cnt, 0) 						/ max_date_MOE_student_interventions, NULL) AS ratio_SSEE_cnt
	,IIF(max_date_MOE_enrolment > 30			, 365.0 * COALESCE(tert_study_any_days, 0) 				/ max_date_MOE_enrolment, NULL)				AS ratio_tert_study_any_days
	,IIF(max_date_MOH_public_hospital_event > 30, 365.0 * COALESCE(time_in_hospital_days, 0) 			/ max_date_MOH_public_hospital_event, NULL) AS ratio_time_in_hospital_days
	,IIF(max_date_POL_pre_count_offenders > 30	, 365.0 * COALESCE(offences_violent_cnt, 0) 			/ max_date_POL_pre_count_offenders, NULL)	AS ratio_offences_violent_cnt
	,IIF(max_date_IRD_ems > 30					, 365.0 * COALESCE(WS_income_period_dollars, 0) 		/ max_date_IRD_ems, NULL)					AS ratio_WS_income_period_dollars
	,IIF(max_date_CYF_fgc > 30					, 365.0 * COALESCE(yj_fgc_cnt, 0) 						/ max_date_CYF_fgc, NULL)					AS ratio_yj_fgc_cnt
	,IIF(max_date_CYF_placements > 30			, 365.0 * COALESCE(yj_placement_cnt, 0) 				/ max_date_CYF_placements, NULL)			AS ratio_yj_placement_cnt
	,IIF(max_date_MOE_student_interventions > 30, 365.0 * COALESCE(alt_ed_cnt, 0)						/ max_date_MOE_student_interventions, NULL) AS ratio_alt_ed_cnt
	,IIF(max_date_MOE_student_interventions > 30, 365.0 * COALESCE(attendance_service_days, 0)			/ max_date_MOE_student_interventions, NULL) AS ratio_attendance_service_days
	,IIF(max_date_MOE_student_interventions > 30, 365.0 * COALESCE(learning_support_cnt, 0)				/ max_date_MOE_student_interventions, NULL) AS ratio_learning_support_cnt
	,IIF(max_date_CYF_roc > 30					, 365.0 * COALESCE(ot_report_concern_cnt, 0)			/ max_date_CYF_roc, NULL)					AS ratio_ot_report_concern_cnt
	,IIF(max_date_avoid_hosp > 30				, 365.0 * COALESCE(avoid_hosp_cnt, 0)					/ max_date_avoid_hosp, NULL)				AS ratio_avoid_hosp_cnt

	,YEAR(period_start) as year
FROM [SIA_Sandpit].[DL-MAA2023-46].[$COHORT_time_series_master_table]
GO
