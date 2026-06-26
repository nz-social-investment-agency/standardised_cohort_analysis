################################################################################
#' Automate generation of checking tool interpretation structure
#' 
#' Uses components of the checker package and compact user input to accelerate
#' generation of output checking tool interpretation instructions.
#' 
#' Inputs and instructions
#' 1) folder_path
#' The folder that contains the files to check. Expects paired CSV files where
#' each pair has the same name except of the text 'RAW' or 'CONF'. For example:
#' 'output_CONF.csv', 'output_RAW.csv', 'CONF extra.csv', 'RAW extra.csv'.
#' Files should have no header information or row number. Column names should
#' appear in row 1 of the file.
#' If a filename starts with a symbol, then the file is skipped.
#' 
#' 2) column_types
#' A named numeric vector containing the names of all the output columns and a
#' number that corresponds to their index in the lookup. All columns omitted
#' from this vector are treated as label columns.
#' For example:
#' - "count_people" is a raw unweighted count of individuals
#' - lookup shows this type has index 2
#' - so `column_types = c("count_people" = 2)`
#' 
#' 3) column_links
#' A named list containing the names of all the output columns and a length-3
#' array listing the columns required to check this column are per the entry
#' in the lookup.
#' For example:
#' - "total_appointment" is a conf. value magnitude, total of individuals
#' - lookup shows checking requires a raw count of individuals, no second entry,
#'   and can take a raw count of entities (entities are optional).
#' - In the linked raw file the raw count column is "num_ppl" and the entity
#'   column is "mha_ent".
#' - so `column_links = list("total_appointment" = c("num_ppl", NA, "mha_ent"))`
#' 
################################################################################

## Lookup - uncomment and run to complete `column_types` and `column_links` ----

# lookup <- checker:::load_refence_tables()$lookup |>
#   dplyr::mutate(index = as.character(dplyr::row_number())) |>
#   dplyr::select("index", "column_type", "type_aux", dplyr::starts_with("link_"))
# View(lookup)

## User parameters -------------------------------------------------------- ----

# folder containing files for submission
folder_path <- "/mnt/DataLab/MAA/MAA2026-04/Cohorts pipeline - matching/4 For submission"

column_types <- c(
  "conf_count_all_people" = 3,
  "conf_count_w_indicator" = 3,
  "conf_annualised_total" = 20,
  "conf_stddev_ratio" = 50,
  "count_all_people" = 2,
  "count_w_indicator" = 2,
  "annualised_total" = 19,
  "stddev_ratio" = 50,
  "education_entity" = 45,
  "enterprise_entity" = 45,
  "pbn_entity" = 45,
  "primhd_entity" = 45,
  "cohort_education_entity" = 45,
  "cohort_enterprise_entity" = 45,
  "cohort_pbn_entity" = 45,
  "cohort_primhd_entity" = 45,
  "min_entity" = 45
)

# linking column names as per lookup: first, second, entity
column_links = list(
  "conf_count_all_people" = c("count_all_people", NA, NA),
  "conf_count_w_indicator" = c("count_w_indicator", NA, "min_entity"),
  "conf_annualised_total" = c("count_w_indicator", NA, "min_entity"),
  "conf_stddev_ratio" = c("count_w_indicator", NA, "min_entity")
)

## Print progress information for user ------------------------------------ ----
run_time_inform_user <- function(msg) {
  stopifnot(is.character(msg))
  now <- as.character(Sys.time())
  now <- substr(now, 1, 19)
  msg <- paste0(now, " | ", msg)
  cat(msg, "\n")
  return(invisible(msg))
}

## Automate the generation of the interpretation structure ---------------- ----
create_interpretation_structure <- function(folder_path) {
  
  files <- list.files(folder_path)
  files_conf <- files[grepl("CONF", files, fixed = TRUE)]
  files_raw <- files[grepl("RAW", files, fixed = TRUE)]
  
  # ensure valid pairs
  trim_files_conf <- gsub("CONF", "", files_conf, fixed= TRUE)
  trim_files_raw <- gsub("RAW", "", files_raw, fixed= TRUE)
  diff <- setdiff(union(trim_files_conf, trim_files_raw), intersect(trim_files_conf, trim_files_raw))
  
  if (length(diff) > 1) {
    diff = paste(diff, collapse = ", ")
    warning(glue::glue("{diff} has missing CONF or RAW pair"))
  }
  
  # create and unnest interpretation structure
  interpretation_structure <- checker:::load_or_create_interpretation_structure(folder_path)
  unnested_IS <- checker::unnest_structure(interpretation_structure)
  unnested_IS <- dplyr::filter(unnested_IS, file %in% union(files_conf, files_raw))
  unnested_IS$table_id <- sort(dplyr::dense_rank(unnested_IS$table_id))
  
  # set values within interpretation structure
  unnested_IS_partial_filled <- create_IS_classification(unnested_IS)
  unnested_IS_filled <- create_IS_linking(unnested_IS_partial_filled)
  
  #convert to nested
  nested_IS_filled <- checker::nest_structure(unnested_IS_filled)
  stopifnot(checker::is_interpretation_structure(nested_IS_filled, nested = TRUE))

  # save interpretation structure
  checker::write_interpretation_structure(nested_IS_filled, folder = folder_path)
  return(nested_IS_filled)
}

## classify talbes and columns - generating interpretation structure ------ ----
create_IS_classification <- function(unnested_IS) {
  stopifnot(is.data.frame(unnested_IS))
  
  # table classification
  unnested_IS <- dplyr::mutate(
    unnested_IS,
    for_release = ifelse(grepl("CONF", file, fixed = TRUE), "y", "n"),
    tabular = "y",
    num_preface_rows = 0,
    num_header_rows = 1
  )
  
  # column classification
  ref_tables <- checker:::load_refence_tables()
  lookup <- dplyr::mutate(ref_tables$lookup, index = dplyr::row_number())
  
  for (i in seq_len(nrow(unnested_IS))) {
    col_name <- unnested_IS$column_display_name[i]
    
    # if column name not found, then label
    if (! col_name %in% names(column_types)) {
      unnested_IS$column_type[i] <- "Label"
      next
    }
    
    lookup_idx <- lookup$index == column_types[[col_name]]
    col_type <- lookup$column_type[lookup_idx]
    aux_type <- lookup$type_aux[lookup_idx]
    
    stopifnot(length(col_type) == 1)
    unnested_IS$column_type[i] <- col_type
    unnested_IS$type_aux[i] <- aux_type
  }
  return(unnested_IS)
}

## link tables and columns - generating interpretation structure ---------- ----
create_IS_linking <- function(unnested_IS) {
  stopifnot(is.data.frame(unnested_IS))
  
  # table linking
  conf_tables = unnested_IS$file[grepl("CONF", unnested_IS$file, fixed = TRUE)]
  conf_tables = unique(conf_tables)
  expected_raw_tables = gsub("CONF", "RAW", conf_tables, fixed = TRUE)
  
  for(ii in seq_along(conf_tables)){
    this_raw = unnested_IS$file == expected_raw_tables[ii]
    this_id = unique(unnested_IS$table_id[this_raw])
    stopifnot(length(this_id) == 1)
    
    this_conf = unnested_IS$file == conf_tables[ii]
    unnested_IS$link_raw_table_id[this_conf] = this_id
  }
  
  link_columns_to_fill = c("link_column_1", "link_column_2", "link_raw_entity_column")
  
  # every row
  for(ii in seq_len(nrow(unnested_IS))){
    # skip not for release and no linking instructions
    if(
      is.na(unnested_IS$for_release[ii]) ||
      unnested_IS$for_release[ii] != "y" ||
      !unnested_IS$column_display_name[ii] %in% names(column_links)
    ){
      next
    }
    
    # locate & assign
    this_col = unnested_IS$column_display_name[ii]
    this_raw_table = unnested_IS$link_raw_table_id[ii]
    
    for(jj in 1:3){
      this_raw_column = column_links[[this_col]][jj]
      this_column_to_fill = link_columns_to_fill[jj]
      
      # skip NA
      if(is.na(this_raw_column)){
        next
      }
      
      raw_column_id = dplyr::filter(
        unnested_IS,
          .data$table_id == this_raw_table,
          .data$column_display_name == this_raw_column
        )
      raw_column_id = raw_column_id$column_id[1]
      
      unnested_IS[[this_column_to_fill]][ii] = raw_column_id
    }
  }
  
  return(unnested_IS)
}

## detail structure checks for column classification and linking ---------- ----
check_columns <- function(nested_IS, type) {
  stopifnot(is.data.frame(nested_IS))
  stopifnot(type %in% c("classification", "linking"))
  
  ref_tables <- checker:::load_refence_tables()
  
  dist_ids <- sort(unique(nested_IS$table_id))
  valid_ids <- c()
  results_df <- data.frame()
  
  for (i in dist_ids) {
    if (type == "classification") {
      results <- checker::review_column_classification(nested_IS, ref_tables$lookup, table_id = i)
    } 
    if (type == "linking") {
      results <- checker::review_column_linking(nested_IS, table_id = i, ref_tables$lookup, ref_tables$desc)
    }
    if (results$type == "ready") {
      valid_ids <- c(valid_ids, i)
    }
    results_df <- rbind(results_df, results)
  }
  
  if (length(valid_ids) != length(dist_ids)) {
    diff <- setdiff(dist_ids, valid_ids)
    diff <- paste(diff, collapse = ", ")
    msg <- glue::glue("Column {type} review failed: check table_ids {diff}")
    run_time_inform_user(msg)
  }
  return(results_df)
}

## confirm valid structure setup for checking ----------------------------- ----
check_valid_IS <- function(nested_IS) {
  stopifnot(is.data.frame(nested_IS))
  stopifnot(checker::is_interpretation_structure(nested_IS, nested = TRUE))
  
  is_exists <- checker::review_file_existence(nested_IS)
  is_tab <- checker::review_tabular_for_release(nested_IS)
  is_header <- checker::review_preface_header_rows(nested_IS)
  is_class <- check_columns(nested_IS, type = "classification")
  is_linked <- check_columns(nested_IS, type = "linking")
  
  check_results <- rbind(is_exists, is_tab, is_header, is_class, is_linked)
  
  if (!all(check_results$type == "ready")) {
    run_time_inform_user("Failed checks")
    check_failures <- check_results[check_results$type != 'ready', ]
    print(check_failures)
  }
  return(check_results)
}

## execute all checks ----------------------------------------------------- ----
execute_checking <- function(nested_IS, folder_path) {
  # load reference tables from package
  ref_tables = checker:::load_refence_tables()
  
  # run the checking tool on the interpretation structure - with time markers
  run_time_inform_user("Started checking")
  checking_results = checker::check_all_files(nested_IS, ref_tables$lookup, ref_tables$desc)
  run_time_inform_user("Finished checking")
  
  # write out results
  output_file <- paste0("checking_results ", gsub(":", "", Sys.time()), ".csv")
  write.csv(checking_results, file.path(folder_path, output_file), row.names = FALSE)
  run_time_inform_user(glue::glue("results saved to {output_file} for review"))
  
  # give summary of results
  run_time_inform_user(glue::glue("Checks run:    {nrow(checking_results)}"))
  run_time_inform_user(glue::glue("Checks passed: {sum(checking_results$pass)}"))
  run_time_inform_user(glue::glue("Checks failed: {nrow(checking_results) - sum(checking_results$pass)}"))
  
  return(invisible(checking_results))
}

############################################################################
# Execution
run_time_inform_user("Auto checker started")

# checks
stopifnot(exists("folder_path"), exists("column_types"), exists("column_links"))
stopifnot(is.character(folder_path))
stopifnot(dir.exists(folder_path))
stopifnot(is.numeric(column_types))
column_types_is_fully_nammed = !is.null(names(column_types)) && all(!is.na(names(column_types)) & names(column_types) != "")
stopifnot(column_types_is_fully_nammed)
column_links_is_fully_nammed = !is.null(names(column_links)) && all(!is.na(names(column_links)) & names(column_links) != "")
stopifnot(column_links_is_fully_nammed)
stopifnot(all(sapply(column_links, length) == 3))

# make interpretation structure
nested_IS_filled <- create_interpretation_structure(folder_path)
run_time_inform_user("Values set for interpretation structure")

# confirm interpretation structure is valid
valid_interpretation_structure <- check_valid_IS(nested_IS_filled)
stopifnot(all(valid_interpretation_structure$type == "ready"))
run_time_inform_user("Confirmed interpretation structure is valid")

# run checks
results = execute_checking(nested_IS_filled, folder_path)
run_time_inform_user("Auto checker complete")
