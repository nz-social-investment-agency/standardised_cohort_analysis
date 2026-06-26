/**************************************************************************************************
Title: ACC Supports
Author: Charlotte Rose
Peer review: 

Inputs & Dependencies:
- [IDI_Clean_$(REFRESH)].[acc_clean].[payments]
- [IDI_Clean_$(REFRESH)].[acc_clean].[claims]

Description:
Identifies people receiving support from ACC, as distinct from injuries which are a sinlge event


Intended purpose:
Indicator to give an idea of how many people are being actively supported by ACC, be it medical appointments or long term programmes or payments

Notes:
- First payment and last payments are within the stated quarter, it is unclear whether this is a payment date for the row, but for this use case, 'any' in the quarter is fine.


Parameters & Present values:
  Current refresh = $(REFRESH)
  Project schema = [$(PROJECT_SCHEMA)]
 
Issues:
 
History (reverse order):
2026-05-18 CR initial
**************************************************************************************************/

 --:SETVAR PROJECT_DB "SIA_Sandpit"
 --:SETVAR PROJECT_SCHEMA "DL-MAA2026-04"
 --:SETVAR REFRESH "202603"

/* DEFINITION */

USE IDI_USERCODE;
GO

DROP VIEW IF EXISTS [$(PROJECT_SCHEMA)].[defn_ACC_supports_$(REFRESH)]; -- stand-downs, suspensions, exclusions & expulsions
GO

CREATE VIEW [$(PROJECT_SCHEMA)].[defn_ACC_supports_$(REFRESH)] AS 

SELECT [snz_uid]
      ,[acc_pay_service_year]
      ,[acc_pay_service_quarter]
      ,[acc_pay_focus_group_text]
      ,[acc_pay_gl_account_text]
      ,[acc_pay_first_service_date] --First date within the quarter a service was provided, for each claim and within each GL_Acount
      ,[acc_pay_last_service_date] -- Last date within the quarter a service was provided, for each claim and within each GL_Acount
      ,[acc_pay_maori_healing_ind]
      ,[acc_pay_number_payments_nbr]
      ,[acc_pay_total_costs_amt]
  FROM [IDI_Clean_$(REFRESH)].[acc_clean].[payments] p
  INNER JOIN [IDI_Clean_$(REFRESH)].[acc_clean].[claims] c
  ON p.snz_acc_claim_uid = c.snz_acc_claim_uid
  GO
