/**************************************************************************************************
Title: Special Needs Grant (SNG) for basic necessities
Author: Charlotte Rose
Peer review: 

Inputs & Dependencies:
- [IDI_Community].[inc_ise_adhoc].[ise_adhoc_202603]

Outputs:
- [IDI_UserCode].[DL-MAA2026-04].[defn_SNG_basics_202603]

Description:
Special Needs Grant (SNG) for basic necessities

Intended purpose:
Identifying who has received a Special Needs Grant (SNG) from MSD for basic necessities

Notes:
- Basic necessities have been chosen on face value and are open to refinement

Parameters & Present values:
  Current refresh = 202603
  Prefix = defn_
  Project schema = [DL-MAA2026-04]


Issues:


History (reverse order):
2026-04-10 CR v1
**************************************************************************************************/
 --:SETVAR PROJECT_DB "SIA_Sandpit"
 --:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
 --:SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_SNG_basics_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_SNG_basics_$(REFRESH)] AS
 SELECT snz_uid
	, benefit_lvl1
	, payment_reason_lvl1
	, payment_start
	, payment_end
  FROM [IDI_Community].[inc_ise_adhoc].[ise_adhoc_$(REFRESH)]
  WHERE [benefit_lvl1] = 'Special Needs Grant'
  AND payment_type_code IN ( --Basic Necessities
								071	--Accommodation
								, 083	--Bedding
								, 074	--Clothing
								, 072	--Electricity, Gas
									-- houshold
								, 080	--Beds, Table, Chairs
								, 075	--Telephone Installation
								, 081	--Washing Machines, Fridge
									-- children
								, 065	--School Stationery
								, 064	--School Uniforms
								)




