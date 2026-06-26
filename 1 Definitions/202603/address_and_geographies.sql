/*******************************************************************************
Address information with higher geographies

Inputs used:
[IDI_Clean_$(REFRESH)].[data].[address_notification]
[IDI_Metadata_$(REFRESH)].[data].[dep_index18_mb18]
[IDI_Metadata_$(REFRESH)].[data].[mb_higher_geo]
max_date SNZ address_notification.sql >> [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_SNZ_address_notification]

- Need to update the concordance mapping when new MB mapping available
- NOTES FOR REFRESH: 202604 updates the higher geo metadata, updated mapping, check if ok to still use dep_23 for mapping
- as no later date

Updates
2026-04-07 CR updated meshblocks to 2026, added DHBs back in

*******************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_address_higher_geog_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_address_higher_geog_$(REFRESH)] AS
-- latest date in dataset
WITH max_date AS (
	SELECT TOP 1 max_date
	FROM [IDI_UserCode].[$(PROJECT_SCHEMA)].[max_date_SNZ_address_notification_$(REFRESH)]
)
SELECT snz_uid
	,an.[snz_idi_address_register_uid]
	,an.ant_meshblock_code 
	,an.ant_notification_date
	,an.ant_replacement_date AS raw_ant_replacement_date
	,IIF(an.ant_replacement_date < max_date, an.ant_replacement_date, max_date) AS ant_replacement_date -- spells end at max_date
	
	,hg.[IUR2026_V1_00] -- urban/rural classification
    ,hg.[IUR2026_V1_00_NAME]
	,CAST(hg.[REGC2025_V1_00] AS INT) AS REGC -- Regional Council
	,hg.[REGC2025_V1_00_NAME] AS REGC_NAME
	,CAST(hg.[TALB2026_V1_00] AS INT) AS TALB -- Territorial Authority or Local Board
	,hg.[TALB2026_V1_00_NAME] AS TALB_NAME
	,CAST(hg.[SA22026_V1_00] AS INT) AS SA2 -- Statistical Area 2 (neighbourhood)
	,hg.[SA22026_V1_00_NAME] AS SA2_NAME
	,CAST(hg.[SA32026_V1_00] AS INT) AS SA3 -- Statistical Area 3 (aggregated urban SA2 to suburbs and rural SA2 to approx 5k-10k residents)
	,hg.[SA32026_V1_00_NAME] AS SA3_NAME
	,oldhg.DHB2015_V1_00 AS DHB
	,oldhg.DHB2015_V1_00_NAME AS DHB_NAME

	,IIF(hg.IUR2026_V1_00 IN (21,22), hg.[TALB2026_V1_00], hg.UR2026_V1_00) AS swa_urban_rural
	,CASE
		WHEN hg.[IUR2026_V1_00_NAME] IN ('Rural settlement', 'Rural other', 'Oceanic', 'Inlet', 'Inland water') THEN 2
		WHEN hg.[IUR2026_V1_00_NAME] IS NULL THEN -99
		ELSE 1
		END AS swa_urban_rural_ind

	,dep.[NZDep2023]
	,CEILING(CASE WHEN dep.[NZDep2023] = '' THEN 0 ELSE dep.[NZDep2023] END /5.0) AS [NZDep2023_binary] -- maybe need to change this 0 to -99?
	,CASE	WHEN dep.[NZDep2023] BETWEEN 1 AND 2 THEN '1 very_low'
			WHEN dep.[NZDep2023] BETWEEN 3 AND 4 THEN '2 low'
			WHEN dep.[NZDep2023] BETWEEN 5 AND 6 THEN '3 moderate'
			WHEN dep.[NZDep2023] BETWEEN 7 AND 8 THEN '4 high'
			WHEN dep.[NZDep2023] BETWEEN 9 AND 10 THEN '5 very_high'
			ELSE '9 unknown'
			END AS NZdep_granular

	-- Geographical Classifications for Health
	--,gch.[gch] AS gch_class
	--,IIF(gch.[gch] = 'U1', 1, NULL) AS GCH_U1
	--,IIF(gch.[gch] = 'U2', 1, NULL) AS GCH_U2
	--,IIF(gch.[gch] = 'R1', 1, NULL) AS GCH_R1
	--,IIF(gch.[gch] = 'R2', 1, NULL) AS GCH_R2
	--,IIF(gch.[gch] = 'R3', 1, NULL) AS GCH_R3

FROM IDI_Clean_$(REFRESH).[data].[address_notification] AS an
INNER JOIN [IDI_Metadata_$(REFRESH)].[data].[meshblock_concordance] AS mc
	ON mc.[MB2026_code] = an.[ant_meshblock_code]
LEFT JOIN [IDI_Metadata_$(REFRESH)].[data].[mb_higher_geo] AS hg
	ON mc.[MB2026_code] = hg.[MB2026_V1_00]
-- Geographical Classifications for DHB has been removed, so using old refresh
LEFT JOIN   (SELECT distinct [DHB2015_V1_00]
      ,[DHB2015_V1_00_NAME]
      ,[HDOM2013_V1_00]
      ,[HDOM2013_V1_00_NAME]
        FROM [IDI_Metadata_202510].[data].[mb_higher_geo]
	) as oldhg
on hg.HDOM2013_V1_00=oldhg.HDOM2013_V1_00

LEFT JOIN [IDI_Metadata_$(REFRESH)].[data].[dep_index23_mb23] AS dep
	ON mc.[MB2023_code] = dep.[MB2023_code]
-- Geographical Classifications for Health uses older MB code
--LEFT JOIN [IDI_Metadata].[clean_read_CLASSIFICATIONS].[meshblock_current_higher_geography] AS hg_old
	--ON mc.[MB2018_code] = hg_old.[MB2018_V1_00]
--LEFT JOIN [$(PROJECT_DB)].[$(PROJECT_SCHEMA)].[gch_sa1_2018] AS gch
	--ON hg_old.[SA12018_V1_00] = gch.[sa1]
CROSS JOIN max_date
WHERE an.[ant_meshblock_code] IS NOT NULL 
GO
