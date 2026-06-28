/**************************************************************************************************
Title: Initialise master table for forecast matching
Author: Simon Anastasiadis
Peer review:

Inputs & Dependencies:
- [IDI_Clean].[data].[personal_detail]
- [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603]
- [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603]

Intended purpose:
Initialise the master table that will be used to construct the forecast cohort
by matching clients to possible_target_matches.

Notes:

Parameters & Present values:
	Project database = SIA_Sandpit
	Project schema = DL-MAA2026-04
	Pipeline prefix = CHT_
	Cohort term for injection = _test
	Current refresh = 202603

Issues:
 
History (reverse order):
2025-08-26 SA version 1
**************************************************************************************************/

-------------------------------------------------------------------------------
-- Initialise as empty table

DROP TABLE IF EXISTS [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]
GO

CREATE TABLE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (
	id_num			INT IDENTITY(1, 7)
	,snz_uid		INT NOT NULL
	,reference_date DATE NOT NULL
	,matching_date DATE NOT NULL
	,age_ref_date	INT NOT NULL
	,snz_mother_uid INT NULL
	,snz_father_uid INT NULL
	,std_start_date	DATE NULL
	,std_end_date	DATE NULL
	,lag_start_date	DATE NULL
	,lag_end_date	DATE NULL
	,to_match	INT DEFAULT 0
)
GO

-------------------------------------------------------------------------------
-- Single point in time per year helper

USE [IDI_UserCode]
GO

DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_tmp_helper_202603]
GO

CREATE VIEW [DL-MAA2026-04].[CHT__test_tmp_helper_202603] AS
SELECT m.[snz_uid]
    ,m.reference_year
	,p.snz_birth_date_proxy
	
	,DATEDIFF(MONTH, p.snz_birth_date_proxy, DATEFROMPARTS(m.reference_year, 03, 31)) / 12 AS age_end_Q1
	,DATEDIFF(MONTH, p.snz_birth_date_proxy, DATEFROMPARTS(m.reference_year, 06, 30)) / 12 AS age_end_Q2
	,DATEDIFF(MONTH, p.snz_birth_date_proxy, DATEFROMPARTS(m.reference_year, 09, 30)) / 12 AS age_end_Q3
	,DATEDIFF(MONTH, p.snz_birth_date_proxy, DATEFROMPARTS(m.reference_year, 12, 31)) / 12 AS age_end_Q4

FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_possible_target_matches_202603] AS m
INNER JOIN [IDI_Clean_202603].[data].[personal_detail] AS p
ON m.snz_uid = p.snz_uid
WHERE p.snz_spine_ind = 1 -- must be on spine
AND p.snz_person_ind = 1 -- must be a person
AND p.snz_birth_date_proxy IS NOT NULL
AND COALESCE(p.snz_deceased_year_nbr, 9999) >= m.reference_year + 2 -- either alive or die 2+ years in future
GO

-------------------------------------------------------------------------------
-- Only populate table if records exist for both tables

IF (
	(SELECT COUNT(*) FROM [IDI_UserCode].[DL-MAA2026-04].[CHT__test_tmp_helper_202603]) >= 10
	AND
	(SELECT COUNT(*) FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603]) >= 10
)
BEGIN -- startconditional population of table

	-------------------------------------------------------------------------------
	-- Add possible matches in each quarter

	-- Quarter 1: ref_date = 20xx-03-31
	INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, reference_date, matching_date, age_ref_date)
	SELECT snz_uid
		,DATEFROMPARTS(reference_year, 03, 31) AS reference_date
		,DATEFROMPARTS(reference_year, 03, 31) AS matching_date
		,age_end_Q1 AS age_ref_date
	FROM [IDI_UserCode].[DL-MAA2026-04].[CHT__test_tmp_helper_202603]
	
	-- Quarter 2: ref_date = 20xx-06-30
	INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, reference_date, matching_date, age_ref_date)
	SELECT snz_uid
		,DATEFROMPARTS(reference_year, 06, 30) AS reference_date
		,DATEFROMPARTS(reference_year, 06, 30) AS matching_date
		,age_end_Q2 AS age_ref_date
	FROM [IDI_UserCode].[DL-MAA2026-04].[CHT__test_tmp_helper_202603]
	
	-- Quarter 3: ref_date = 20xx-09-30
	INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, reference_date, matching_date, age_ref_date)
	SELECT snz_uid
		,DATEFROMPARTS(reference_year, 09, 30) AS reference_date
		,DATEFROMPARTS(reference_year, 09, 30) AS matching_date
		,age_end_Q3 AS age_ref_date
	FROM [IDI_UserCode].[DL-MAA2026-04].[CHT__test_tmp_helper_202603]
	
	-- Quarter 4: ref_date = 20xx-12-31
	INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, reference_date, matching_date, age_ref_date)
	SELECT snz_uid
		,DATEFROMPARTS(reference_year, 12, 31) AS reference_date
		,DATEFROMPARTS(reference_year, 12, 31) AS matching_date
		,age_end_Q4 AS age_ref_date
	FROM [IDI_UserCode].[DL-MAA2026-04].[CHT__test_tmp_helper_202603]
	
	-------------------------------------------------------------------------------
	-- Ensure no to-match identities are available to match to

	DELETE FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]
	WHERE snz_uid IN (SELECT snz_uid FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603])
	
	-------------------------------------------------------------------------------
	-- Insert records to match

	INSERT INTO [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, reference_date, matching_date, age_ref_date, to_match)
	SELECT c.snz_uid
		,reference_date
		,reference_date AS matching_date
		,DATEDIFF(MONTH, p.snz_birth_date_proxy, c.reference_date) / 12 AS age_ref_date
		,1 AS to_match
	FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_target_202603] AS c
	INNER JOIN [IDI_Clean_202603].[data].[personal_detail] AS p
	ON c.snz_uid = p.snz_uid
	WHERE p.snz_birth_date_proxy IS NOT NULL

-------------------------------------------------------------------------------
END -- end conditional population of table
GO

-------------------------------------------------------------------------------
-- Index for update

CREATE NONCLUSTERED INDEX i_uid ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid)
GO

-------------------------------------------------------------------------------
-- Add std and lag dates

-- batch process to reduce server demand
DECLARE @i INT = 0
DECLARE @num_batches INT = 32 

WHILE @i < @num_batches
BEGIN 

	UPDATE [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]
	SET 
		std_end_date	= reference_date
		,std_start_date	= DATEADD(DAY, 1, DATEADD(YEAR, -1, reference_date)) -- one day less that a full year
		,lag_end_date	= DATEADD(YEAR, -1, reference_date)
		,lag_start_date	= DATEADD(DAY, 1, DATEADD(YEAR, -2, reference_date)) -- one day less that two full years
	WHERE snz_uid % @num_batches = @i

	SET @i = @i + 1
END
GO

-------------------------------------------------------------------------------
-- Add parents

-- batch process to reduce server demand
DECLARE @i INT = 0
DECLARE @num_batches INT = 32 

WHILE @i < @num_batches
BEGIN 

	UPDATE mt
	SET snz_mother_uid = p.snz_parent1_uid
		,snz_father_uid = IIF(p.snz_parent2_uid = p.snz_parent1_uid,NULL,p.snz_parent2_uid)
	FROM [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] AS mt
	INNER JOIN [IDI_Clean_202603].[data].[personal_detail] AS p
	ON mt.snz_uid = p.snz_uid
	WHERE mt.snz_uid % @num_batches = @i

	SET @i = @i + 1
END
GO

-------------------------------------------------------------------------------
-- Tidy up

DROP VIEW IF EXISTS [DL-MAA2026-04].[CHT__test_tmp_helper_202603]
GO
DROP INDEX i_uid ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603]
GO

-------------------------------------------------------------------------------
-- Index

CREATE NONCLUSTERED INDEX i_uid_std_date ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, std_start_date, std_end_date)
CREATE NONCLUSTERED INDEX i_uid_lag_date ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (snz_uid, lag_start_date, lag_end_date)
CREATE NONCLUSTERED INDEX i_references	 ON [SIA_Sandpit].[DL-MAA2026-04].[CHT__test_forecast_matching_master_table_202603] (age_ref_date, reference_date)
GO
