################################################################################
# Search plain text files for specified text
# Simon Anastasiadis
# 2026-04-09
# 
# It is sometimes necessary to search a large number of files to see whether
# any contain specific text. This code does so, producing a csv summary of all
# files and lines scanned.
################################################################################

## user parameters -------------------------------------------------------- ----

# location to analyse
FOLDER_TO_ANALYSE = "~/Network-Shares/DataLabNas/MAA/MAA2023-46/"

# output file name
OUTPUT_FILE_NAME = "found_text_in_files.csv"
# your output will be saved in the directory being analysed

# keyword to search for (accepts regex, some defaults provided)
KEYWORD = "my_keyword"
# KEYWORD = "[0-9]{6}" # finds all refreshes (six consecutive numbers)
# KEYWORD = "MAA20[0-9][0-9]-[0-9][0-9]" # finds all schemas in the form MAA20XX-YY
# KEYWORD = "TOP " # For checking if any SQL scripts contain the TOP keyword

# accepted file extensions (plain text only - i.e. not .docx or .xlsx)
accepted_extensions = c(".R", ".sql", ".sas", ".Rmd", ".do")

## setup ------------------------------------------------------------------ ----

# setup
output_df = data.frame(stringsAsFactors = FALSE)
warn_option = getOption("warn")
options(warn = -1)

## scan every file -------------------------------------------------------- ----

for(each_file in dir(path = FOLDER_TO_ANALYSE, recursive = TRUE)){
  # skip if file missing accepted extension
  this_extension = paste0(".", tools::file_ext(each_file))
  if(!this_extension %in% accepted_extensions){
    next
  }
  
  # initialize for file
  line_number = 0
  out_lines = 0
  this_file_df = data.frame(stringsAsFactors = FALSE)
  
  # read file
  con = file(file.path(FOLDER_TO_ANALYSE, each_file), "r")
  while( TRUE ){
    line_number = line_number + 1
    line = readLines(con, n = 1)
    
    # stop at end of document
    if(length(line) == 0){
      break
    }
    # record lines with matching keywords
    if(grepl(KEYWORD, line)){
      out_lines = out_lines + 1
      
      this_file_df = rbind(
        this_file_df,
        data.frame(
          msg = "match",
          file = each_file,
          line = line_number,
          contents = line,
          stringsAsFactors = FALSE
        )
      )
    }
  }
  # done reading file
  close(con)
  
  # record file to output df
  output_df = rbind(
    output_df,
    data.frame(
      msg = "file checked",
      file = each_file,
      line = NA_integer_,
      contents = paste(out_lines, "lines found with matches of", line_number, "lines read"),
      stringsAsFactors = FALSE
    ),
    this_file_df
  )
}

## save results ----------------------------------------------------------- ----

options(warn = warn_option)  
write.csv(output_df, file.path(FOLDER_TO_ANALYSE, OUTPUT_FILE_NAME), row.names = FALSE)
