setwd("~/Network-Shares/DataLabNas/MAA/MAA2026-04/projects/Cohorts pipeline - matching/4 For submission/")

cohort_folder <- "~/Network-Shares/DataLabNas/MAA/MAA2026-04/projects/Cohorts pipeline - matching/4 For submission/"
GenPop_folder <- "~/Network-Shares/DataLabNas/MAA/MAA2026-04/projects/Cohorts pipeline - solo/4 For submission/"
#---combine raw files---#
Cohort <- 'Barnardos'


cohort_file_raw <- "RAW BARNARDOS_current_state 202603"
GenPop_file_raw <- "RAW GENPOP_BARNARDOS_current_state 202603"
output_name_raw <- "RAW FULL_BARNARDOS_current_state 202603.csv"
cohort_file_conf <- "CONF BARNARDOS_current_state 202603"
GenPop_file_conf <- "CONF GENPOP_BARNARDOS_current_state 202603"
output_name_conf <- "CONF FULL_BARNARDOS_current_state 202603.csv"
folder <- "~/Network-Shares/DataLabNas/MAA/MAA2026-04/projects/Cohorts pipeline - matching/4 For submission/"

library(dplyr)

## combine raw files ###

combined_raw <- bind_rows(cohort_file_raw,GenPop_file_raw)

colnames(GenPop_file_raw) <- colnames(cohort_file_raw)

write.csv(combined_raw,output_name_raw, row.names = FALSE)

## combine conf files ###

combined_conf <- bind_rows(cohort_file_conf,GenPop_file_conf)

colnames(GenPop_file_conf) <- colnames(cohort_file_conf)

write.csv(combined_conf,output_name_conf, row.names = FALSE)


