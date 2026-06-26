/**************************************************************************************************
Title: MHA combined
Author: Charlotte Rose
Reviewer: Lexi Xu


Citation:
Social Investment Agency. Definitions library. Source code. https://github.com/nz-social-investment-agency/definitions_library

Description:


Intended purpose:
Combines mental health and addiction definitions into broad definitions of 'substance abuse' and 'mental illness'

Inputs & Dependencies:
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_alcohol_abuse_or_dependence_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_drug_abuse_or_dependence_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_major_depressive_disorder_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_bipolar_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_dysthymia_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_generalised_anxiety_disorder_$(REFRESH)]
- [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_schizophrenia_$(REFRESH)]

Outputs:
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[substance_abuse_$(REFRESH)]
- [IDI_UserCode].[$(PROJECT_SCHEMA)].[mental_illness_$(REFRESH)]


Notes:
1) All definitions above must be run for the current refresh before running this script

Issues:
1) 
	
Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
 
History (reverse order):
2025-07-22 CR
*************************************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"


USE IDI_UserCode
GO

--Substance abuse--

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_substance_abuse_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_substance_abuse_$(REFRESH)] AS
	(
		SELECT snz_uid
			, event_date 
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_alcohol_abuse_or_dependence_$(REFRESH)]

		UNION ALL

		SELECT snz_uid
			, event_date 
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_drug_abuse_or_dependence_$(REFRESH)]
	)
GO

--Mental illness--
DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_mental_illness_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_mental_illness_$(REFRESH)] AS
	(

		SELECT snz_uid
		, event_date
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_major_depressive_disorder_$(REFRESH)]

		UNION ALL

		SELECT snz_uid 
			, event_date
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_bipolar_$(REFRESH)]

		UNION ALL

		SELECT snz_uid 
			, event_date
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_dysthymia_$(REFRESH)]

		UNION ALL

		SELECT snz_uid 
			, event_date
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_generalised_anxiety_disorder_$(REFRESH)]

		UNION ALL

		SELECT snz_uid 
			, event_date
		FROM [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[defn_mha_schizophrenia_$(REFRESH)]

		UNION ALL

		SELECT snz_uid
			, moh_mhd_activity_start_date AS event_date
		FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[defn_MHA_service_use_$(REFRESH)]
		WHERE TEAM_TYPE_DESCRIPTION <> 'Alcohol and Drug Team' --not AOD (captured in substance abuse definition)
	)
GO
