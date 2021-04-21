#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(tidyverse))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a table of ORF coverage statistics.
Author: A. Jo Williams-Newkirk at ***REMOVED***
Dependencies:
R packages: docopt, testthat
Usage: config.R -a <analysisDirFP> [-s <pacbamFileSuf> -b <bedFile1FP> -t <bedFile2FP> -p <pacbamDirFP> -m <minCov>]
config.R (-v | --version)
config.R (-h | --help)
Options:
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>    Cecret output directory full path; string
-b <bedFile1FP> --bedFile1FP=<bedFile1FP>             Bed file 1 with full path; string [default: ../configs/MN908947.3-ORFs.bed]
-t <bedFile2FP> --bedFile2FP=<bedFile2FP>             Bed file 2 with full path; string [default: ../configs/MN908947.3-ORF7b.bed]
-p <pacbamDirFP> --pacbamDirFP=<pacbamDirFP>          PacBam output directory full path; string [default: pacbam_orfs]
-s <pacbamFileSuf> --pacbamFileSuf=<pacbamFileSuf>    PacBam output file suffic; string [default: .primertrim.sorted.pileup]
-m <minCov> --minCov=<minCov>                         Minimum coverage threshold to call a position; integer [default: 30]
-h --help                                             Show this help and exit
-v --version                                          Show version and exit"

args <- docopt(doc = doc, version = ver)

# Read in the bed files and format in single table
bedTemp <- read_tsv(args$bedFile2FP, 
                    col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH")) %>%
           select(-TRASH, -REF, -POOL)
bedRegions <- read_tsv(args$bedFile1FP, 
                       col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH")) %>%
              select(-TRASH, -REF, -POOL) %>%
              bind_rows(bedTemp) %>%
              arrange(START)
print(bedRegions)