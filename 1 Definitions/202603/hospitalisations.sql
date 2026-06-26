/**************************************************************************************************
Title: Hosptial visits

Inputs & Dependencies:
- [IDI_Clean].[moh_clean].[pub_fund_hosp_discharges_event]
- [IDI_Clean].[moh_clean].[priv_fund_hosp_discharges_event]

Description:
A stay in a hospital, public or private.

Intended purpose:
Counting hospital admissions, bed nights, duration of stay, hospitalisation.

Notes:

Parameters & Present values:
  Current refresh = $(REFRESH)
  Prefix = defn_
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:

History (reverse order):
2026-04-10 SA added header to file lacking one, original author unknown
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_hospitalisations_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_hospitalisations_$(REFRESH)] AS

SELECT [snz_uid]
      ,[moh_evt_evst_date] as [start_date]
      ,[moh_evt_even_date] as [end_date]
	  ,'PUBLIC' as [type]
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[pub_fund_hosp_discharges_event]

UNION ALL

SELECT [snz_uid]
      ,[moh_pri_evt_start_date]
      ,[moh_pri_evt_end_date]
	  ,'PRIVATE' as [type]
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[priv_fund_hosp_discharges_event]
GO
