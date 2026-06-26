/**************************************************************************************************
Title: Mental Health Service Use
Author: Simon Anastasiadis

Inputs & Dependencies:
- [IDI_Clean].[moh_clean].[PRIMHD]
- [IDI_Metadata].[clean_read_CLASSIFICATIONS].[moh_primhd_team_code]
Outputs:
- [IDI_UserCode].[DL-MAA2016-15].[defn_MHA_service_use]

Description:
Use of mental mealth and addictions services as recorded in PRIMHD.

Intended purpose:
Determining who has accessed mental health and addiction services.
 
Notes:
1) While the GMS table codes both health cards as Y(es) or N(o),
   the pharmaceutical table uses a different coding of health cards:
   HUHC in (NULL, U, Z)
   CSC in (NULL, 1, 3, 4)
   Based on the proportion of the population in each category, we has assumed
   HUHC = Z and CSC = 1 or 3 are equivalent to Yes, and the others are equivalent to No.
2) Several activity types are excluded:
   T08	Care/liaison co-ordination contacts
   T32	Contact with family/whanau, consumer not present
   T33	Seclusion
   T35	Did not attend
   T37	On leave

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [DL-MAA2016-15]

Issues:
 
History (reverse order):
2020-05-20 SA v1
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

/* Set database for writing views */
USE IDI_UserCode
GO

/* Clear existing view */

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_MHA_service_use_$(REFRESH)];
GO

/* Create view */
CREATE VIEW [$(PROJECT_SCHEMA)].[defn_MHA_service_use_$(REFRESH)] AS
SELECT [snz_uid]
      ,[moh_mhd_activity_start_date]
      ,[moh_mhd_activity_end_date]
      ,[moh_mhd_activity_type_code]
      ,[moh_mhd_activity_status_code]
      ,[moh_mhd_activity_unit_type_text]
	  ,TEAM_TYPE_DESCRIPTION
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[PRIMHD]
INNER JOIN [IDI_Metadata_$(REFRESH)].[moh_primhd].[team_code] 
ON moh_mhd_team_code = TEAM_CODE
WHERE [moh_mhd_activity_type_code] NOT IN ('T35','T32','T33','T37','T08')
GO

