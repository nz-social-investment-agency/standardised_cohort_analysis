################################################################################
# Matching methodology implementation
# 
################################################################################

## Confirm required variables --------------------------------------------- ----

stopifnot(exists("BASE_FOLDER"))
stopifnot(exists("COHORT"))

## Load settings ---------------------------------------------------------- ----

settings_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/Execution/in_progress_settings.RDS")
settings = readRDS(settings_file)

required_settings = c("phase", "assembly_master_table", "matching_results", "db_connection_string", "exact_match_cols")
for(setting in required_settings){
  stopifnot(setting %in% names(settings))
  assign(setting, settings[[setting]])
}

## Other parameters ------------------------------------------------------- ----

max_records_in_R = 400000

# columns not used for matching, only assembly
discard_cols = c(
  "id_num","snz_mother_uid","snz_father_uid","std_start_date","std_end_date",
  "lag_start_date","lag_end_date","dob","REGC_NAME_std","TALB_NAME_std",
  "REGC_NAME_lag","TALB_NAME_lag"
)

Rmd_file = glue::glue("{BASE_FOLDER}/6 Automation/Automation scripts/overview_matching.Rmd")
report_file = glue::glue("{BASE_FOLDER}/2 Analysis/{COHORT}/Output/overview {phase}.html")

## Helper functions - load data ------------------------------------------- ----

# return connection to remote table
remote_table = function(sql_table){
  df = dplyr::tbl(db_connection, IDIr:::sql2id(sql_table))
}

# apply standard filters to master table
standard_filters = function(df){
  
  df = df |>
    # max_date and entity columns should not be in data, excl. in case
    dplyr::select(
      -dplyr::starts_with("max_date_"),
      -dplyr::ends_with("__max"),
      -dplyr::ends_with("__min")
    ) |>
    # compulsory columns
    dplyr::filter(
      !is.na(.data$sex),
      !is.na(.data$urban_rural_std),
      !is.na(.data$REGC_std),
      !is.na(.data$TALB_std),
      !is.na(.data$NZDep_std),
      !is.na(.data$urban_rural_lag),
      !is.na(.data$REGC_lag),
      !is.na(.data$TALB_lag),
      !is.na(.data$NZDep_lag)
    )
  return(df)
}

# number of rows in database table
num_rows = function(df){
  n_rows = df |>
    dplyr::ungroup() |>
    dplyr::summarise(num = dplyr::n()) |>
    dplyr::collect() |>
    dplyr::pull()
  return(n_rows)
}

# collect data
collect_table = function(df, num_records = max_records_in_R){
  
  # denominator
  denominator = ceiling(num_rows(df) / num_records)
  # load into R
  df = df |>
    dplyr::filter(.data$id_num %% denominator == 0 | .data$to_match == 1) |>
    dplyr::collect()
  
  return(df)
}

# data cleaning
standard_cleaning = function(df){
  # remove unneeded columns
  df = df |>
    dplyr::select(-dplyr::all_of(discard_cols))
  
  # all numeric columns: missing >> zero
  df = df |>
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~ dplyr::coalesce(., 0)))
  
  # _cnt_ columns: values within [0, 12]
  df = df |>
    dplyr::mutate(dplyr::across(dplyr::contains("_cnt_"), ~ pmax(.,  0))) |>
    dplyr::mutate(dplyr::across(dplyr::contains("_cnt_"), ~ pmin(., 12)))
  
  # _days_ columns: values within [0, 365]
  df = df |>
    dplyr::mutate(dplyr::across(dplyr::contains("_days_"), ~ pmax(.,   0))) |>
    dplyr::mutate(dplyr::across(dplyr::contains("_days_"), ~ pmin(., 365)))
  
  # _dollars_ columns normalise values to mean 50000 (avoids inflation)
  dollars_cols = colnames(df)
  dollars_cols = dollars_cols[grepl("_dollars_", dollars_cols, fixed = TRUE)]
  
  for(dd in dollars_cols){
    df_values = df[[dd]]
    df_values = df_values[df_values > 0]
    dd_mean = dplyr::coalesce(mean(df_values), 1)
    df[[dd]] = 50000 * df[[dd]] / dd_mean
  }
  
  # _dollars_ columns: values within [1, Inf], logarithm
  df = df |>
    dplyr::mutate(dplyr::across(dplyr::contains("_dollars_"), ~ pmax(.,   1))) |>
    dplyr::mutate(dplyr::across(dplyr::contains("_dollars_"), ~ log(.)))
  
  return(dplyr::collect(df))
}

## Helper functions - write data ------------------------------------------ ----

drop_sql_table = function(db_connection, sql_table){
  drop_query = glue::glue("DROP TABLE IF EXISTS {sql_table}")
  DBI::dbExecute(db_connection, drop_query)
}

copy_r_to_sql = function(db_connection, sql_table, r_table) {
  suppressMessages( # mutes translation message
    DBI::dbWriteTable(
      db_connection,
      IDIr:::sql2id(sql_table),
      r_table
    )
  )
}

## Matching methodology function ------------------------------------------ ----

matching_methodology = function(){
  
  ## Skip flag if no data ----
  IDIr::run_time_inform_user("Confirming sufficient rows to run matching")
  
  num_df_rows = remote_table(assembly_master_table) |>
    standard_filters() |>
    num_rows()
  
  skip_flag = ifelse(num_df_rows <= 10, TRUE, FALSE)
  
  if(skip_flag){
    IDIr::run_time_inform_user("Skipping - ensuring empty output table")
    
    drop_sql_table(db_connection, matching_results)
    
    empty_df = data.frame(snz_uid = numeric(0), reference_date = as.Date(numeric(0)))
    copy_r_to_sql(db_connection, matching_results, empty_df)
    
    return(invisible(NULL))
  }
  
  ## Drop RC and TALB if insufficient variation ----
  IDIr::run_time_inform_user("Confirming extent of geospatial variation")
  
  area_variation = remote_table(assembly_master_table) |>
    standard_filters() |>
    dplyr::filter(.data$to_match == 1) |>
    dplyr::group_by(REGC_std) |>
    dplyr::summarise(num = dplyr::n()) |>
    dplyr::collect()
  
  area_variation_flag = max(area_variation$num) / sum(area_variation$num) <= 0.6
  
  if(!area_variation_flag){
    IDIr::run_time_inform_user("Limited geospatial variation - omitting RC and TALB from matching")
    discard_cols = c(discard_cols, "TALB_std", "TALB_lag", "REGC_std", "REGC_lag")
  }
  
  ## Model fitting ----
  IDIr::run_time_inform_user("Fitting logit model")
  
  df = remote_table(assembly_master_table) |>
    standard_filters() |>
    collect_table() |>
    standard_cleaning()
  
  # fit logit model for matching - all columns except snz_uid and reference_date
  withCallingHandlers(
    {
      matching_model = glm(
        to_match ~ .,
        data = dplyr::select(df, -"snz_uid", -"reference_date"),
        family = binomial(link = "logit")
      )
    },
    # prevents warnings from derailing process
    warning = function(w){
      msg = paste(w$message, collapse = "\n")
      IDIr::run_time_inform_user(paste("Warning during logit: ", msg))
      invokeRestart("muffleWarning")
    }
  )
  
  ## Matching setup ----
  
  # combinations to iterate through
  iter_combinations = remote_table(assembly_master_table) |>
    standard_filters() |>
    dplyr::filter(to_match == 1) |>
    dplyr::select(dplyr::all_of(exact_match_cols)) |>
    dplyr::distinct() |>
    dplyr::collect()
  
  # store for matched identities
  matched_records = list()
  
  matching_remote_df = remote_table(assembly_master_table) |>
    standard_filters()
  
  ## Matching each combination ----
  
  for(ii in seq_len(nrow(iter_combinations))){
    msg = glue::glue("Matching combination {ii} of {nrow(iter_combinations)}")
    IDIr::run_time_inform_user(msg)
    
    df = matching_remote_df
    for(col in exact_match_cols){
      value = iter_combinations[[col]][ii]
      df = dplyr::filter(df, .data[[col]] == value)
    }
    df = collect_table(df) |>
      standard_cleaning()
    
    # skip if missing people to match or people for matching
    if(sum(df$to_match == 1) == 0){
      next
    }
    if(sum(df$to_match == 0) == 0){
      next
    }
    
    withCallingHandlers(
      {
        # fit model
        df$predicted_prob = predict(matching_model, newdata = df, type = "response")
        
        model_matched = MatchIt::matchit(
          formula = to_match ~ .,
          data = df,
          method = "nearest",
          distance = df$predicted_prob, # use probabilities as distance
          ratio = 2,                    # two matches for each input
          exact = exact_match_cols
        )
      },
      # prevents warnings from derailing process
      warning = function(w){
        msg = paste(w$message, collapse = "\n")
        IDIr::run_time_inform_user(paste("Warning during logit: ", msg))
        invokeRestart("muffleWarning")
      }
    )
    
    # matched records
    matched_df = df[as.numeric(c(model_matched$match.matrix)),] |>
      dplyr::select("snz_uid", "reference_date") |> 
      dplyr::filter(!is.na(snz_uid))
    matched_records = c(matched_records, list(matched_df))
  }
  
  # copy matched snz_uids to SQL
  drop_sql_table(db_connection, matching_results)
  copy_r_to_sql(db_connection, matching_results, dplyr::bind_rows(matched_records))
  
  ## Conclude ----
  return(matching_model)
}

## Matching reporting function -------------------------------------------- ----

matching_reporting = function(matching_model){
  
  ## Skip if no data ----
  num_df_rows = remote_table(assembly_master_table) |>
    standard_filters() |>
    num_rows()
  
  skip_flag = ifelse(num_df_rows <= 10, TRUE, FALSE)
  if(skip_flag){
    return(invisible(NULL))
  }
  
  ## Setup ----
  IDIr::run_time_inform_user("Setup for reporting")
  
  # base table
  df = remote_table(assembly_master_table) |>
    standard_filters()
  
  # matched records
  matched_df = remote_table(matching_results)
  
  local_matched_df = df |>
    dplyr::semi_join(matched_df, by = c("snz_uid", "reference_date")) |>
    collect_table() |>
    dplyr::mutate(treat_control_other = 'control')
  
  # client and unmatched records
  df = df |>
    dplyr::anti_join(matched_df, by = c("snz_uid", "reference_date")) |>
    collect_table(num_records = max_records_in_R - nrow(local_matched_df)) |>
    dplyr::mutate(treat_control_other = ifelse(to_match == 1, 'treat', 'other'))
  
  # ready
  df = dplyr::bind_rows(df, local_matched_df) |>
    standard_cleaning()
  
  ## Matching all combinations ----
  IDIr::run_time_inform_user("Approximate matching for reporting")
  
  withCallingHandlers(
    {
      # fit model
      df$predicted_prob = predict(matching_model, newdata = df, type = "response")
      
      model_matched = MatchIt::matchit(
        formula = to_match ~ .,
        data = dplyr::select(df, -"snz_uid", -"treat_control_other"),
        method = "nearest",
        distance = df$predicted_prob, # use probabilites as distance
        ratio = 2,                    # two matches for each input
        exact = exact_match_cols
      )
    },
    # prevents warnings from derailing process
    warning = function(w){
      msg = paste(w$message, collapse = "\n")
      IDIr::run_time_inform_user(paste("Warning during logit: ", msg))
      invokeRestart("muffleWarning")
    }
  )
  
  ## Report performance ----
  
  # reduce size of df to save memory before render
  df = dplyr::select(
    df,
    "snz_uid", "to_match", "predicted_prob", "treat_control_other"
  )

  IDIr::run_time_inform_user("Generating matching report")
  rmarkdown::render(
    input = Rmd_file,
    params = list(
      df = df,
      model_matched = model_matched
    ),
    output_file = report_file,
    quiet = TRUE
  )
}

## Execution -------------------------------------------------------------- ----

db_connection = DBI::dbConnect(odbc::odbc(), .connection_string = db_connection_string)

matching_model = matching_methodology()
matching_reporting(matching_model)
rm("matching_model")

DBI::dbDisconnect(db_connection)
