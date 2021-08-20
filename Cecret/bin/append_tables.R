#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(tidyverse))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to merge two tables in delimited files. By default overwrites input file 1.
Author: A. Jo Williams-Newkirk at ***REMOVED***
Support: SC2CLIA-Cecret@cdc.gov
Dependencies:
R packages: docopt, testthat, tidyverse
Usage: append_tables.R -a <analysisDirFP> -f <file1FP> -s <file2FP> [-o <outputFileFP> -d <delimiter1> -e <delimiter2> -i <idCol1> -c <idCol2>]
append_tables.R (-v | --version)
append_tables.R (-h | --help)
Options:
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>    Cecret output directory full path; string
-f <file1FP> --file1FP=<file1FP>                      Table file 1 full path; string
-s <file2FP> --file2FP=<file2FP>                      Table file 2 full path; string
-o <outputFileFP> --outputFileFP=<outputFileFP>       Output file full path; string [default: file1FP]
-d <delimiter1> --delimiter1=<delimiter1>             Delimiter for file 1, accepts 't' or 'c' for tab or comma [default: t]
-e <delimiter2> --delimiter2=<delimiter2>             Delimiter for file 2, accepts 't' or 'c' for tab or comma [default: t]
-i <idCol1> --idCol1=<idCol1>                         Column name in file 1 containing info for matching between files, if NULL performs string matching to ID column; string [default: NULL]
-c <idCol2> --idCol2=<idCol2>                         Column name in file 2 containing info for matching between files; string [default: Sample.ID]
-l <elimsCol> --elimsCol=<elimsCol>                   T/F indicating whether or not to append extra eLIMS columns Percent Mapped Reads and GenBank number; logical [default: TRUE]
-h --help                                             Show this help and exit
-v --version                                          Show version and exit"

### Comments ###
# BY DEFAULT THIS SCRIPT WILL OVERWRITE INPUT FILE 1! Change this behavior by explicitly setting output file in args.
# By default this script assumes you're matching the column Sample.ID in input file 2 to any column in input file 1 that has regex matches to Sample.ID. It doesn't even require that all regex matches come from the same column.
# If you set the columns to match specific columns in args, the script assumes these columns contain identical strings and won't perform any regex matching. It will still match accurately if the samples are in different order in the two tables.
# The 2 output files are the output table (by default overwriting input file 1) and the log file, which will go in the analysisDirFP/logs directory under either append_table_log.(tsv|txt) depending on the type of matching. If using regex matching, the tsv log will record any columns across both tables that contain "sample" in the name and the MATCH_COL so there's a record of which samples where merged between tables. If exact matching, txt will record that's what happened.

### Set and validate input args ###

# Parse input args
args <- docopt(doc = doc, version = ver)

# Validate input args
test_that("all input args are valid", {
  expect_true(file.exists(args$file1FP))
  expect_true(file.exists(args$file2FP))
  expect_match(args$delimiter1, "[t^c]")
  expect_match(args$delimiter2, "[t^c]")
  expect_type(as.logical(args$elimsCol), "logical")
})
if (args$outputFileFP != "file1FP") {
  test_that("output file locations are valid", {
    expect_true(directory.exists(basename(args$outputFileFP)))
    expect_true(directory.exists(file.path(basename(args$outputFileFP), "logs")))
  })
}
# Translate delimiters from args
f1Delim <- ifelse(args$delimiter1 == "t", "\t", ",")
f2Delim <- ifelse(args$delimiter2 == "t", "\t", ",")

# This flag controls whether table rows are matched on user-specified columns or using fuzzy matching
fuzzyFlag <- ifelse(args$idCol1 == "NULL", TRUE, FALSE)

# This flag controls whether or not 2 additional fields for eLIMS outputs are appended to the final summary.txt output.
elimsFlag <- ifelse(args$elimsCol == "TRUE", TRUE, FALSE)

# Translate output file from args
if (args$outputFileFP == "file1FP") {
  outFile <- args$file1FP
} else {
  outFile <- args$outputFileFP
}

### Terrible Functions ###

# Originally part of matcher1; split up for slightly better flow control
matcher2 <- function(tempX, tempY, c, s) {
  # where tempX and tempY are tibbles passed in from matcher1
  # where c is a string, the column ID for y to use for row matching
  # where s is the index of the current Sample.ID being matched from tempY in tempX
  # returns match if found or NA if no match found. Error for multiple matches
  for (n in colnames(tempX)) {
    maybeMatch <- str_which(tempX[[n]], tempY[[c]][s])
    if (length(maybeMatch) == 0) { 
      # no matches in the column, check the next column
      next
    } else {
      if (length(maybeMatch) == 1) {
        # exactly one match in this column, return MATCH_COL value from matched row
        return(tempX$MATCH_COL[maybeMatch])
      } else {
        # multiple matches throw error
        errorCondition(message = paste0("ERROR: multiple possible matches of ", tempY$c[s], " in table."))
      }
    }
  }
  return(NA)
}
# Does way too much at once; adds numeric columns to each input tibble to use to merge them later
matcher1 <- function(x, y, c) {
  # where x is a tibble, usually file1, the main table you want to merge to
  # where y is a tibble, usually file2, the secondary table merging into x
  # where c is a string, the column ID for y to use for row matching
  # returns tears and regret in addition to a vector of tibbles x and y that now contain column MATCH_COL.
  MATCH_COL <- seq(1:nrow(x))
  tempX <- cbind(x, MATCH_COL)
  tempY <- mutate(y, MATCH_COL = NA_real_)
  for (s in 1:length(tempY[[c]])) {
    tempY$MATCH_COL[s] <- matcher2(tempX, tempY, c, s)
  }
  return(list(tempX, tempY))
}

### Ingest and format input tables ###

# Read in file1
file1 <- read_delim(file = args$file1FP,
                  col_names = TRUE,
                  quoted_na = FALSE,
                  trim_ws = TRUE,
                  delim = f1Delim,
                  col_types = cols())

# Read in file2
file2 <- read_delim(file = args$file2FP,
                    col_names = TRUE,
                    quoted_na = FALSE,
                    trim_ws = TRUE,
                    delim = f2Delim,
                    col_types = cols())

test_that('input tables have same number of rows', {
  expect_equal(nrow(file1), nrow(file2))
})

# Unless turned off, add columns for eLIMS to output
if (elimsFlag == TRUE) {
  file1 <- mutate(file1, 
                  `GenBank#` = "")
}

### Match rows between columns ###
if (fuzzyFlag == FALSE) {
  outTable <- left_join(file1, 
                        file2, 
                        by = c(args$idCol1, args$idCol2))
  logComment <- paste0("Explicitly matched on columns ", 
                       args$idCol1, 
                       " and ", 
                       args$idCol2, 
                       ".")
} else {
  newTibbles <- matcher1(file1, file2, args$idCol2)
  outTable <- left_join(newTibbles[[1]], 
                        newTibbles[[2]], 
                        by = "MATCH_COL") %>%
              select(-Sample.ID, -MATCH_COL)
  logTable <- left_join(newTibbles[[1]], 
                        newTibbles[[2]], 
                        by = "MATCH_COL") %>%
              select(contains("sample", 
                              ignore.case = TRUE),
                     MATCH_COL)
}

### Write out files ###

write_tsv(outTable, 
          file = outFile, 
          col_names = TRUE)
if (exists("logTable") == TRUE) {
  write_tsv(logTable, 
            file = file.path(args$analysisDirFP, 
                             "logs", 
                             "append_table_log.tsv"), 
            col_names = TRUE)
} else {
  if (exists("logComment") == TRUE) {
    write_file(logComment,
               file = file.path(args$analysisDirFP, 
                                "logs", 
                                "append_table_log.txt"))
  }
}
