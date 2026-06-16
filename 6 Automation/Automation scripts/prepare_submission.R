################################################################################
# Make raw and conf files for output submission
# 
################################################################################

## User parameters -------------------------------------------------------- ----

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/in_progress_settings.RDS")

req_raw_cols = c(
  "organisation_name",
  "client_status",
  "period",
  "dimension1_type",
  "dimension1_code",
  "dimension2_type",
  "dimension2_code",
  "indicator",
  "category",
  "category_key",
  "count_all_people",
  "count_w_indicator",
  "conf_count_all_people",
  "conf_count_w_indicator",
  "annualised_total",
  "stddev_ratio",
  "conf_annualised_total",
  "conf_stddev_ratio",
  "education_entity",
  "enterprise_entity",
  "pbn_entity",
  "primhd_entity",
  "cohort_education_entity",
  "cohort_enterprise_entity",
  "cohort_pbn_entity",
  "cohort_primhd_entity",
  "min_entity",
  "max_date",
  "extract_date"
)

req_conf_cols = c(
  "organisation_name",
  "client_status",
  "period",
  "dimension1_type",
  "dimension1_code",
  "dimension2_type",
  "dimension2_code",
  "indicator",
  "category",
  "category_key",
  "conf_count_all_people",
  "conf_count_w_indicator",
  "conf_annualised_total",
  "conf_stddev_ratio",
  "max_date",
  "extract_date"
)

## Load settings ---------------------------------------------------------- ----

settings = readRDS(settings_file)

required_settings = c("phase", "conf_summary_file", "raw_for_submission_file",
                      "conf_for_submission_file", "client_table", "db_connection_string")
for(setting in required_settings){
  stopifnot(setting %in% names(settings))
  assign(setting, settings[[setting]])
}

## Load inputs ------------------------------------------------------------ ----

df = read.csv(conf_summary_file)

is_current_state = grepl("current state", phase)
is_time_series = grepl("time series", phase)

stopifnot(is_current_state | is_time_series)

## tidy current state ----------------------------------------------------- ----

if(is_current_state){
  # separate count all people and count w indicator
  all_peopleNZ = df |>
    dplyr::filter(
      dim1_type == 'country',
      is.na(dim2_type),
      is.na(indicator),
    ) |>
    dplyr::select("client_status", "period", "count_all_people", "conf_count_all_people")
  
  all_people = df |>
    dplyr::filter(
      is.na(dim2_type) | dim2_type %in% df$denominator,
      is.na(indicator)
    ) |>
    dplyr::select(
      "client_status", "period", "dim1_type", "dim1_code", "dim2_type", "count_all_people", "conf_count_all_people"
    ) |>
    dplyr::rename(denominator = dim2_type) |>
    dplyr::mutate(denominator = dplyr::coalesce(denominator, "Standard"))
  
  df = df |>
    dplyr::rename(count_w_indicator = count_all_people, conf_count_w_indicator = conf_count_all_people) |>
    dplyr::left_join(all_peopleNZ, by = c("client_status", "period")) |>
    dplyr::rename(count_all_peopleNZ = count_all_people, conf_count_all_peopleNZ = conf_count_all_people) |>
    dplyr::left_join(all_people, by = c("client_status", "period", "dim1_type", "dim1_code", "denominator")) |>
    
    # replace count all people where dimension2 and indicator are NA, to give the nationwide total, otherwise keep it as the Regional/TA total
    dplyr::mutate (
      count_all_people = dplyr::if_else(is.na(indicator), count_all_peopleNZ, count_all_people),
      conf_count_all_people = dplyr::if_else(is.na(indicator), conf_count_all_peopleNZ, conf_count_all_people),
      indicator = dplyr::coalesce(indicator, "population")
    ) |>
    # drop the separate nationwide total column
    dplyr::select(-count_all_peopleNZ,-conf_count_all_peopleNZ)
  
  # Align columns with expected names
  mapping_csv = read.csv(glue::glue("{BASE_FOLDER}/6 Automation/Mappings/mapping - dimension1.csv"))
  df = df |>
    dplyr::left_join(mapping_csv, by = c("dim1_type", "dim1_code"))
  
  mapping_csv = read.csv(glue::glue("{BASE_FOLDER}/6 Automation/Mappings/mapping - dimension2.csv"))
  df = df |>
    dplyr::left_join(mapping_csv, by = c("dim2_type", "dim2_code"))
  
  # remove drop rows
  df = df |>
    dplyr::filter(is.na(dimension1_code) | dimension1_code != "DROP")
  
  df = df |>
    dplyr::filter(is.na(dimension2_code) | dimension2_code != "DROP")
  
  # rows missing dimensions
  if(any(is.na(df$dimension1_type))){
    warning(
      "NAs detected in dimension.\n",
      "Cause is likely missing entries in dimension1 mapping csv."
    )
  }
  
  if(any(is.na(df$dimension2_type))){
    warning(
      "NAs detected in dimension.\n",
      "Cause is likely missing entries in dimension2 mapping csv."
    )
  }
  
  # rounding correction (to ensure threshold 20 is respected)
  if(all(c("count_all_people", "conf_count_all_people") %in% colnames(df))){
    df$conf_count_all_people = ifelse(!is.na(df$conf_count_all_people) & df$count_all_people == 19, 18, df$conf_count_all_people)
    df$conf_count_all_people = ifelse(!is.na(df$conf_count_all_people) & df$count_all_people == 20, 21, df$conf_count_all_people)
  }
  if(all(c("count_w_indicator", "conf_count_w_indicator") %in% colnames(df))){
    df$conf_count_w_indicator = ifelse(!is.na(df$conf_count_w_indicator) & df$count_w_indicator == 19, 18, df$conf_count_w_indicator)
    df$conf_count_w_indicator = ifelse(!is.na(df$conf_count_w_indicator) & df$count_w_indicator == 20, 21, df$conf_count_w_indicator)
  }
}

## metadata fetch --------------------------------------------------------- ----

if(is_current_state){
  
  db_connection = DBI::dbConnect(odbc::odbc(), .connection_string = db_connection_string)
  remote_client_table = dplyr::tbl(db_connection, IDIr:::sql2id(client_table))
  
  # fetch values
  loaded_obs = dplyr::summarise(remote_client_table, num = dplyr::n())
  loaded_obs = dplyr::collect(loaded_obs)
  
  current_nonlinked = dplyr::filter(remote_client_table, linked_uid != 1, current_client == 1)
  current_nonlinked = dplyr::summarise(current_nonlinked, num = dplyr::n())
  current_nonlinked = dplyr::collect(current_nonlinked)
  
  noncurrent_nonlinked = dplyr::filter(remote_client_table, linked_uid != 1, current_client != 1)
  noncurrent_nonlinked = dplyr::summarise(noncurrent_nonlinked, num = dplyr::n())
  noncurrent_nonlinked = dplyr::collect(noncurrent_nonlinked)
  
  DBI::dbDisconnect(db_connection)
  
  # prepare for inclusion
  values = c(
    dplyr::coalesce(loaded_obs$num[1], 0),
    dplyr::coalesce(current_nonlinked$num[1], 0),
    dplyr::coalesce(noncurrent_nonlinked$num[1], 0)
  )
  conf_values = IDIr::apply_random_rounding(values, seeds = values)
  conf_values[conf_values < 6] = NA
  
  metadata_df = data.frame(
    organisation_name = rep(COHORT, 3),
    period = rep("system", 3),
    indicator = c("loaded_obs", "current_nonlinked", "noncurrent_nonlinked"),
    count_w_indicator = values,
    conf_count_w_indicator = conf_values,
    education_entity = 9999,
    enterprise_entity = 9999,
    pbn_entity = 9999,
    primhd_entity = 9999,
    cohort_education_entity = 9999,
    cohort_enterprise_entity = 9999,
    cohort_pbn_entity = 9999,
    cohort_primhd_entity = 9999
  )
  
  # bind
  df = dplyr::bind_rows(metadata_df, df)
}

## tidy time series ------------------------------------------------------- ----

if(is_time_series){
  # period to text
  df = dplyr::mutate(
    df,
    period = dplyr::case_when(
      period == -2 ~ "2yr before",
      period == -1 ~ "1yr before",
      period == +1 ~ "1yr after",
      period == +2 ~ "2yr after",
      period == +3 ~ "3yr after",
      period == +4 ~ "4yr after",
    )
  )
}

## Add blank missing columns ---------------------------------------------- ----

for(cc in req_raw_cols){
  if(cc %in% colnames(df)){
    next
  }
  df[[cc]] = NA
}

## Confidentiality requirements ------------------------------------------- ----

# minimum entity for output checking tool
df = dplyr::mutate(df, min_entity = pmin(
  .data$education_entity, 
  .data$enterprise_entity, 
  .data$pbn_entity, 
  .data$primhd_entity, 
  .data$cohort_education_entity, 
  .data$cohort_enterprise_entity, 
  .data$cohort_pbn_entity, 
  .data$cohort_primhd_entity
))

# discard where too few people with indicator
# (due to join this is equivalent to discarding fully suppressed rows)
df = dplyr::filter(df, !is.na(conf_count_w_indicator))

## Write outputs ---------------------------------------------------------- ----

# add extraction date
df$extract_date = as.character(Sys.Date())

# confidential excludes raw and entity columns

df |>
  dplyr::select(dplyr::all_of(req_raw_cols)) |>
  write.csv(raw_for_submission_file, row.names = FALSE)

df |>
  dplyr::select(dplyr::all_of(req_conf_cols)) |>
  write.csv(conf_for_submission_file, row.names = FALSE)
