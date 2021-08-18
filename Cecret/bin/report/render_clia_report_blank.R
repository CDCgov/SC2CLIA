#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(rmarkdown))
suppressMessages(library(tidyverse))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a blank CLIA report with signature page commonly used when generating CLIA validation packages for review.

Author: A. Jo Williams-Newkirk at ***REMOVED***
Support: SC2CLIA-Cecret@cdc.gov

Dependencies:
R packages: docopt, testthat, rmarkdown, tidyverse

Usage: render_clia_report_blank.R [-r <inputRMD> -t <inputTEX> -s <inputSig> -d <outputDir> -o <outputFile>]
config.R (-v | --version)
config.R (-h | --help)

Options:
-r <inputRMD> --inputRMD=<inputRMD>         Input RMD file with path as needed; string [default: ../Cecret/bin/report/clia_summary.Rmd]
-t <inputTEX> --inputTEX=<inputTEX>         Input TEX file with path as needed; string [default: ../Cecret/bin/report/clia_headers.tex]
-s <inputSig> --inputSig=<inputSig>         Input signature template pdf with path as needed; string [default: ../Cecret/bin/report/clia_sig_page.pdf]
-d <outputDir> --outputDir=<outputDir>      Output directory with path as needed; string [default: ../Cecret/bin/report]
-o <outputFile> --outputFile=<outputFile>   Output file name without path; string [default: SC2_Variant_WGS_Run_Summary_blank.pdf]
-h --help                                   Show this help and exit
-v --version                                Show version and exit"

# Parse input args
args <- docopt(doc = doc, version = ver)

# Test the input args for validity
test_that("Input files are .RMD, .TEX, and .PDF and exist", {
  expect_match(args$inputRMD, "*.Rmd$", ignore.case = TRUE)
  expect_true(file.exists(args$inputRMD))
  expect_match(args$inputTEX, "*.tex$", ignore.case = TRUE)
  expect_true(file.exists(args$inputTEX))
  expect_match(args$inputSig, "*.pdf$", ignore.case = TRUE)
  expect_true(file.exists(args$inputSig))
  })

test_that("Output file is PDF without path and output directory exists", {
  expect_true(dir.exists(args$outputDir))
  expect_match(args$outputFile, "*.pdf$", ignore.case = TRUE)
  expect_false(str_detect(args$outputFile, "/"))
  })

# Render the blank data pdf
rmarkdown::render(input = args$inputRMD, 
                  output_file = "intermediate_blank.pdf",
                  output_dir = args$outputDir,
                  output_format = "pdf_document", 
                  # The only param that matters here is the runNormal flag, which is what triggers the production of the blank tables. The others are just arbitrary placeholders to get the file to render.
                  params = list(analysisDirFP = "not/Real/Dir", 
                                runID = "testRun", 
                                seqDirFP = "not/Real/Dir", 
                                runNormal = FALSE))

# Merge blank data pdf with template signature page
system2(command = "pdftk",
        args = c(file.path(args$outputDir, "intermediate_blank.pdf"), 
                 file.path(args$inputSig),
                 "cat",
                 "output",
                 file.path(args$outputDir, args$outputFile)),
        wait = TRUE)

# Clean up intermediate file
if (file.exists(file.path(args$outputDir, "intermediate_blank.pdf"))) {
  system2(command = "rm",
          args = c(file.path(args$outputDir, "intermediate_blank.pdf")),
          wait = TRUE)
}