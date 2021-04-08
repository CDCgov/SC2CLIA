#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a report from Cecret pipeline outputs in HTML.

Author: A. Jo Williams-Newkirk at ***REMOVED***

Dependencies:
R packages: docopt, testthat

Usage: config.R -r <runID> [-t <title> -p <runPath> -s <samplesheet>]
config.R (-v | --version)
config.R (-h | --help)

Options:
-r <runID> --runID=<runID>        Sequencing run ID; string
-p <runPath> --runPath=<runPath>  Path to run directory given in runID; string [default: '../../run']
-t <title> --title=<title>        Report title; string [default: 'Cecret Report']
-s <sampleSheet> --ss=<ss>        Sample sheet file name (CSV only); string [default: 'SampleSheet.csv']

-d <day>, --day=<day>           User's birth day; numeric 1-31
-y <year>, --year=<year>        User's birth year; numeric 1900-2016
-l <lucky>, --lucky=<lucky>     Receive your lucky numbers for the day; recognized options include 'career' and 'love'; string (optional)
--age_years                     Flag; prints user's age in years instead of days (optional)
-h --help                       Show this help and exit
-v --version                    Show version and exit"

args <- docopt(doc = doc, version = ver)

library(tidyverse)

sumFile <- read_tsv(paste0(args$runPath,
                           "/",
                           args$runID,
                           "/",
                           args$sumSheet))
bwaV <- sumFile$aligner_version[1]
ivarV <- sumFile$ivar_version[1]

# rmarkdown::render_site(params = list(ssheet = args$samplesheet,
#                                       ))

# will need to cp multiQC report file from fastqc into _site directory when complete unless can find a workaround.