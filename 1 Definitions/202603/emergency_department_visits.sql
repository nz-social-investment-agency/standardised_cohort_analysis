/**************************************************************************************************
Title: Emergency Department visit
Author: Craig Wright

Inputs & Dependencies:
- [IDI_Clean].[moh_clean].[nnpac]

Description:
Emergency Department (ED) visits at hospital.

Intended purpose:
Identifying presentation at an emergency department, counting number of ED visits.

Notes:

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:

History (reverse order):
2026-04-10 SA copied header into file missing one
2021-10-31 CW
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_emergency_department_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_emergency_department_$(REFRESH)] AS

SELECT DISTINCT [snz_uid]
      ,CAST([moh_nnp_service_datetime] AS DATE) AS [start_date]
	  ,CAST([moh_nnp_service_datetime] AS DATE) AS [end_date]
	 -- ,[moh_nnp_purchase_unit_code]
	  ,'ED visit' AS [description]
	  ,'moh nnpac' as [source]
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[nnpac]
WHERE [moh_nnp_event_type_code] = 'ED'
AND [moh_nnp_purchase_unit_code] IN ('ED02001', 'ED02001A', 'ED03001', 'ED03001A',
									 'ED04001', 'ED04001A', 'ED05001', 'ED05001A',
									 'ED06001', 'ED06001A')
AND [moh_nnp_service_date] IS NOT NULL
AND [moh_nnp_service_type_code] <> 'FU' /*do not include "follow-up" (FU) appointments. 
--See 'inclusion criteria' on page 34 of: www.health.govt.nz/publication/emergency-department-use-2014-15*/
AND [moh_nnp_attendence_code] <> 'DNA' /*Remove cases when health care user "Did not attend"*/
AND [moh_nnp_attendence_code] <> 'DNW' /*Remove cases when health care user arrived but "did not wait" to use service.
--See 'inclusion criteria' on page 34 of: www.health.govt.nz/publication/emergency-department-use-2014-15*/
GO
