/**************************************************************************************************
Title: Categorised offenses and victimisations recorded by Police
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [IDI_Clean].[pol_clean].[pre_count_offenders]
- [IDI_Clean].[pol_clean].[pre_count_victimisations]
- offences_categorised.csv

Description:
Offences and victimisations as recorded by Police with flags for violence, non-violence,
alcohol, and drug offences.
For use provided more nuance about what kind of crime has occurred.


Notes:
- Original table used for classification is the metadata table:
	[IDI_Metadata_202510].[moj].[offence_code]
- Classification done by SIA staff based on ANZSOC code descriptions.
	Seriousness score, Offence typology description, and ANZSOC categories
	were used to guide the classification.
- Most alcohol events are drink driving related.
- There is some overlap between alcohol and drug events, so it may be worth considering a combined category.

Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
 
History (reverse order):
2025-03-14 SA
2024-11-12 CW original reference
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"
-- :SETVAR SQL_FOLDER "\\prtprdsasnas01\DataLab\MAA\MAA2026-04\Cohorts pipeline - matching\1 Defitions\202603"

-------------------------------------------------
-- Load offence table
-------------------------------------------------

DROP TABLE IF EXISTS [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories]
GO

CREATE TABLE [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories] (
	OFFENCE_CODE VARCHAR(4)
	,OFFENCE_DESCRIPTION VARCHAR(250)
	,anzsoc VARCHAR(4)
	,anzsoc_group_code_name VARCHAR(250)
	,IS_DRIVING_UNDER_INFLUENCE_FLG CHAR(1)
	,violent TINYINT
	,alcohol TINYINT
	,drug TINYINT
)
GO

BULK INSERT [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories]
FROM '$(SQL_FOLDER)\offences_categorised.csv'
WITH (
	FIRSTROW = 2,
	FORMAT = 'CSV'
)
GO

CREATE NONCLUSTERED INDEX i_code ON [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories] (OFFENCE_CODE)
GO

-------------------------------------------------
-- Offences and Victimisations
-------------------------------------------------

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_police_offence_categorised_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_police_offence_categorised_$(REFRESH)] AS
SELECT a.[snz_uid]
	,[snz_pol_occurrence_uid]
	,[snz_pol_offence_uid]
	,a.pol_pro_proceeding_date
	,a.pol_pro_offence_code
	,a.pol_pro_anzsoc_offence_code

	,b.IS_DRIVING_UNDER_INFLUENCE_FLG
	,b.violent
	,b.alcohol
	,b.drug
	,IIF(a.pol_pro_proceeding_date < DATEADD(YEAR,18,p.snz_birth_date_proxy),1,NULL) as youth
FROM [IDI_Clean_$(REFRESH)].[pol_clean].[pre_count_offenders] as a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories] as b
ON a.pol_pro_offence_code = b.OFFENCE_CODE
INNER JOIN [IDI_Clean_$(REFRESH)].[data].[personal_detail] p
ON p.snz_uid = a.snz_uid


GO


DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_police_victim_categorised_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_police_victim_categorised_$(REFRESH)] AS
SELECT [snz_uid]
	,[snz_pol_occurrence_uid]
	,[snz_pol_offence_uid]

	,a.pol_prv_reported_date
	,a.pol_prv_offence_code
	,a.pol_prv_anzsoc_offence_code
	
	,b.IS_DRIVING_UNDER_INFLUENCE_FLG
	,b.violent
	,b.alcohol
	,b.drug
FROM [IDI_Clean_$(REFRESH)].[pol_clean].[pre_count_victimisations] as a
INNER JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[offence_categories] as b
ON a.pol_prv_offence_code = b.OFFENCE_CODE		
GO
