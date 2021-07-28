#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(rmarkdown))
suppressMessages(library(tidyverse))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a PDF signature page template to be used when generating CLIA reports through the Cecret pipeline.

Author: A. Jo Williams-Newkirk at ***REMOVED***

Dependencies:
R packages: docopt, testthat, rmarkdown

Usage: render_clic_sig.R [-i <inputFile> -d <outputDir> -o <outputFile>]
config.R (-v | --version)
config.R (-h | --help)

Options:
-i <inputFile> --inputFile=<inputFile>      Input RMD file with path as needed; string [default: ../Cecret/bin/report/clia_sig_page.Rmd]
-d <outputDir> --outputDir=<outputDir>      Output directory with path as needed; string [default: ../Cecret/bin/report]
-o <outputFile> --outputFile=<outputFile>   Output file name without path; string [default: clia_sig_page.pdf]
-h --help                                   Show this help and exit
-v --version                                Show version and exit"

# Parse input args
args <- docopt(doc = doc, version = ver)

# Test the input args for validity
test_that("Input file is .RMD and exists", {
  expect_match(args$inputFile, "*.Rmd$", ignore.case = TRUE)
  expect_true(file.exists(args$inputFile))
  })

test_that("Output file is PDF without path and output directory exists", {
  expect_true(dir.exists(args$outputDir))
  expect_match(args$outputFile, "*.pdf$", ignore.case = TRUE)
  expect_false(str_detect(args$outputFile, "/"))
  })

# Render the pdf
rmarkdown::render(input = args$inputFile, output_format = "pdf_document", output_dir = args$outputDir, output_file = args$outputFile)
