#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(stringr))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a report from Cecret pipeline outputs in HTML.

Author: A. Jo Williams-Newkirk at ***REMOVED***

Dependencies:
R packages: docopt, testthat

Usage: config.R -r <runID> [-p <runPath> -s <samplesheet>]
config.R (-v | --version)
config.R (-h | --help)

Options:
-r <runID> --runID=<runID>                         Sequencing run ID; string
-p <runPath> --runPath=<runPath>                   Path to run directory given in runID; string [default: '../../../../runs']
-a <analysisPath> --analysisPath=<analysisPath>    Cecret output directory path; string [default: '../../../']
-s <sampleSheet> --ss=<ss>                         Sample sheet file name (CSV only); string [default: 'SampleSheet.csv']
-h --help                                          Show this help and exit
-v --version                                       Show version and exit"

args <- docopt(doc = doc, version = ver)

# Run bash script to generate list of component versions
# First find the Cecret output directory
outDirs <- list.dirs(path = args$analysisPath,
                     full.names = TRUE,
                     recursive = FALSE)
analysisDir <- str_subset(outDirs, args$runID)
system2('../versions.sh', args = c(analysisDir), wait = TRUE)

# library(tidyverse)

# sumFile <- read_tsv(paste0(args$runPath,
#                            "/",
#                            args$runID,
#                            "/",
#                            args$sumSheet))
# bwaV <- sumFile$aligner_version[1]
# ivarV <- sumFile$ivar_version[1]

# rmarkdown::render_site(params = list(ssheet = args$samplesheet,
#                                       ))

# will need to cp multiQC report file from fastqc into _site directory when complete unless can find a workaround.