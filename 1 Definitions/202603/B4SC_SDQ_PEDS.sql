/**************************************************************************************************
Title: Strengths and Difficulty Scores and Parental Evaluation of Development Status
Author: Charlotte Rose
Peer review: Simon Anastasiadis

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[moh_clean].[b4sc]

Description: 
This uses the before school check (B4SC) results from the Strengths and Difficulties Questionaire (SDQ)
and Parental Evaluation of Development Status (PEDS) to identify an indiviudals status on a variety of behavioural
and developmental areas, at the time of the B4SC. Outcomes based of these results are also included to get an idea of the further support offered/provided

Intended purpose:

Indicator for cohort analysis for to look at young childrens identified needs when they are 4.


Notes:
- For ease and consistancy, this definition uses the B4SC general date rather than the individuasl dates of the questionaire
- Scoring metadata is sourced from MoH (2010) B4SC handbook for practitioners and checked for currency in the following:
	SDQ: Kansas University (2015) Scoring the Strenths & Difficulties Questionnaite for age 4-17 
	PEDS: Centre for Community Child Health Australia (n.d) Introduction to: Parents' Evaluation of Development Status
	These may not directly align with MoHs wording, but at the time of writing the MoH definitions were not easily found
- Latest check date is July 2024 (202603 refresh) 
- B4SC started national roll out in 2008, earliest available data is 2008-01-27, however in the data it appears the monthly figures don't pick up until March 2009
- Comparison rates use all children in the denominator, 'in theory, all 4YO are eligible to receive a B4SC', DHB's send invitations to all parents with 4YO's enrolled with a PHO
- The quality issues seem specific to the SDQ and obesity measures: quality issues with the SDQ tend to relate to teacher responses (sdqt), 
	so following advise from health we limit to parent responses (sdqp).
- Coverage rates increase between 2009-2013 to reach over 90%
- These B4SC are soon to change to be held between the ages of 2-3.

Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
 
History (reverse order):
2025-06-12 CR
**************************************************************************************************/

-- :SETVAR PROJECT_DB "SIA_Sandpit"
-- :SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
-- :SETVAR REFRESH "202603"

USE IDI_UserCode
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_B4SC_SDQ_PEDS_$(REFRESH)]
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_B4SC_SDQ_PEDS_$(REFRESH)] AS
SELECT DISTINCT b.snz_uid
	,b.moh_bsc_general_date
	, 1 AS had_b4SC
	--,[moh_bsc_sdqp_conduct_nbr] --raw score
	--,[moh_bsc_sdqp_emotional_nbr] --raw score
	--,[moh_bsc_sdqp_hyperactive_nbr] --raw score
	--,[moh_bsc_sdqp_peer_prob_nbr] --raw score
	, IIF([moh_bsc_sdqp_outcome_text] = 'Declined',NULL,[moh_bsc_sdqp_conduct_nbr] + [moh_bsc_sdqp_emotional_nbr] + [moh_bsc_sdqp_hyperactive_nbr] + [moh_bsc_sdqp_peer_prob_nbr]) as sdq_score
	, CASE
		WHEN [moh_bsc_sdqp_outcome_text] = 'Declined' THEN 'Declined'
		WHEN [moh_bsc_sdqp_conduct_nbr] + [moh_bsc_sdqp_emotional_nbr] + [moh_bsc_sdqp_hyperactive_nbr] + [moh_bsc_sdqp_peer_prob_nbr] BETWEEN 00 AND 13 THEN 'Normal'
		WHEN [moh_bsc_sdqp_conduct_nbr] + [moh_bsc_sdqp_emotional_nbr] + [moh_bsc_sdqp_hyperactive_nbr] + [moh_bsc_sdqp_peer_prob_nbr] BETWEEN 14 AND 16 THEN 'Borderline'
		WHEN [moh_bsc_sdqp_conduct_nbr] + [moh_bsc_sdqp_emotional_nbr] + [moh_bsc_sdqp_hyperactive_nbr] + [moh_bsc_sdqp_peer_prob_nbr] >= 17 THEN 'Concerning'
		END AS sdq_category -- MoH (2010) B4SC handbook for practitioners 
	, moh_bsc_sdqp_outcome_text
	,IIF([moh_bsc_sdqp_outcome_text] = 'Declined',NULL,[moh_bsc_peds_pathway_code]) as peds_pathway --raw status
	, CASE
		WHEN [moh_bsc_peds_outcome_text] = 'Declined' THEN 'Declined'
		WHEN [moh_bsc_peds_pathway_code] = 'A' THEN 'Two or more signif concern'
		WHEN [moh_bsc_peds_pathway_code] = 'B' THEN 'One signif concern'
		WHEN [moh_bsc_peds_pathway_code] = 'C' THEN 'Non-signif concern'
		WHEN [moh_bsc_peds_pathway_code] = 'D' THEN 'Parent diff communicating'
		WHEN [moh_bsc_peds_pathway_code] = 'E' THEN 'No concerns'
		END AS peds_category -- MoH (2010) B4SC handbook for practitioners 
	,[moh_bsc_peds_outcome_text]
FROM [IDI_Clean_$(REFRESH)].[moh_clean].[b4sc] b
WHERE moh_bsc_general_date IS NOT NULL -- had a B4SC
AND moh_bsc_general_date < GETDATE() -- not in the future
GO
