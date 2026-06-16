/**************************************************************************************************
Fix fo Family Violence and Sexual Violence (FVSV) code module
Exclude young children marked as offenders.
**************************************************************************************************/

USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [DL-MAA2023-46].[defn_FVSV_code_module_FIX_202506]
GO

CREATE VIEW [DL-MAA2023-46].[defn_FVSV_code_module_FIX_202506] AS
SELECT [snz_uid]
      ,[incident_start_date]
      ,[incident_end_date]
      ,[is_FV_flag]
      ,[is_SV_flag]
      ,IIF(codification like 'Y07%',0,[offender_flag]) as [offender_flag]
      ,IIF(codification like 'Y07%',1,[victim_flag]) as [victim_flag]
      ,[source_data]
      ,[codification]
      ,[codification_desc]
      ,[event_id]
      ,[relationship]
      ,[snz_birth_date_proxy]
      ,[snz_sex_gender_code]
      ,[euro]
      ,[maori]
      ,[pacific]
      ,[asian]
      ,[melaa]
      ,[eth_other]
      ,[age_at_incident]
FROM [IDI_Community].[crim_family_sexual_violence].[family_sexual_violence_202506]
WHERE IIF(offender_flag = 1 and age_at_incident <=10 and source_data = 'POL_OFF',1,0) <> 1
