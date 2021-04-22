#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(tidyverse))
suppressMessages(library(rlist))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a table of ORF coverage statistics.
Author: A. Jo Williams-Newkirk at ***REMOVED***
Dependencies:
R packages: docopt, testthat
Usage: config.R -r <runID> -a <analysisDirFP> [-s <pacbamFileSuf> -b <bedFile1FP> -t <bedFile2FP> -p <pacbamDir> -m <minCov>]
config.R (-v | --version)
config.R (-h | --help)
Options:
-r <runID> --runID=<runID>                            Run ID; string
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>    Cecret output directory full path; string
-b <bedFile1FP> --bedFile1FP=<bedFile1FP>             Bed file 1 with full path; string [default: ../configs/MN908947.3-ORFs.bed]
-t <bedFile2FP> --bedFile2FP=<bedFile2FP>             Bed file 2 with full path; string [default: ../configs/MN908947.3-ORF7b.bed]
-p <pacbamDir> --pacbamDir=<pacbamDir>                PacBam output directory name; string [default: pacbam_orfs]
-s <pacbamFileSuf> --pacbamFileSuf=<pacbamFileSuf>    PacBam output file suffic; string [default: .primertrim.sorted.pileup]
-m <minCov> --minCov=<minCov>                         Minimum coverage threshold to call a position; integer [default: 30]
-h --help                                             Show this help and exit
-v --version                                          Show version and exit"

args <- docopt(doc = doc, version = ver)

### Classes ###
# To do: write proper setter and getter functions for classes.
setClass(Class = "CecretORF",
         slots = c(ORF.ID = "character",
                   Mean.Depth = "numeric",
                   Length = "numeric",
                   Num.Ns = "numeric",
                   Num.Min.Cov = "numeric",
                   Percent.Ns = "numeric",
                   Percent.Min.Cov = "numeric"),
         prototype = list(ORF.ID = NA_character_,
                          Mean.Depth = NA_real_,
                          Length = NA_real_,
                          Num.Ns = NA_real_,
                          Num.Min.Cov = NA_real_,
                          Percent.Ns = NA_real_,
                          Percent.Min.Cov = NA_real_))
setClass(Class = "CecretSample",
         slots = c(Sample.ID = "character",
                   ORF1ab = "CecretORF",
                   S = "CecretORF",
                   ORF3a = "CecretORF",
                   E = "CecretORF",
                   M = "CecretORF",
                   ORF6 = "CecretORF",
                   ORF7a = "CecretORF",
                   ORF7b = "CecretORF",
                   ORF8 = "CecretORF",
                   N = "CecretORF",
                   ORF10 = "CecretORF"),
         prototype = list(Sample.ID = NA_character_,
                          ORF1ab = new("CecretORF", ORF.ID = "ORF1ab"),
                          S = new("CecretORF", ORF.ID = "S"),
                          ORF3a = new("CecretORF", ORF.ID = "ORF3a"),
                          E = new("CecretORF", ORF.ID = "E"),
                          M = new("CecretORF", ORF.ID = "M"),
                          ORF6 = new("CecretORF", ORF.ID = "ORF6"),
                          ORF7a = new("CecretORF", ORF.ID = "ORF7a"),
                          ORF7b = new("CecretORF", ORF.ID = "ORF7b"),
                          ORF8 = new("CecretORF", ORF.ID = "ORF8"),
                          N = new("CecretORF", ORF.ID = "N"),
                          ORF10 = new("CecretORF", ORF.ID = "ORF10")))

### Functions ###

# Functions to read in data for a single sample
# Read in consensus sequence
consensusReader <- function(f) {
  # where f = single record consensus file, not wrapped, full path
  # returns 2 item vector.  1 = fasta line 1, 2 = fasta line 2
  consensusIn <- read_lines(f)
  return(consensusIn)
}

# Functions to format data for a single sample
# Formatting consensus data
consensusFormatter <- function(s, v) {
  # where v = 2 item list derived from consensusReader(). 1 = fasta line 1, 2 = fasta line 2
  # where s = Sample.ID record (string). Write check later to confirm fasta line 1 contains Sample ID expected.
  # returns a vector where each letter in consensus is an item in the vector.
  return(unlist(str_split(v[2])))
}

# Functions to subset data by regions in bedRegions
# Subset the consensus data
consensusSplitter <- function(v, b) {
  # where v = consensus vector from consensusFormatter().
  # where b = tibble like bedRegions (should always be bedRegions in this script)
  # returns a list of named vectors corresponding to ORFs in bedRegions (each item is ORFname = vector of sequence)
  orfList <- list()
  for (r in 1:nrow(b)) {
    orfList[b$ORF] <- v[b$START:b$END]
  }
  return(orfList)
}

# Function(s) to calculate mean depth, %pos meeting min cov, #n, %n per region. 
# Calculate #N from consensus data for single ORF
nCounter <- function(v) {
  # where v = vector of sequence for single ORF, as generated by consensusSplitter()
  # returns integer
  # note: case sensitive
  return(str_count(toString(v), "N"))
}
# Calculate percent N in ORF from consensus data
nPercent <- function(n, l) {
  # where n = number Ns in ORF calculated by nCounter()
  # where 1 = length of ORF
  # returns percentage
  return(n / l)
}

# Add value to list of lists (intended for use on outList only)
outputAppender <- function(l, s, n, v) {
  # where l = main list name (should always be outList for now)
  # where s = sample ID, which is the name of the internal list
  # where n = name of the new value (column name) to be added to s's list
  # where v = value to be assigned to n
  # returns updated list
  l[s] <- list.append(l[s], n = v)
  return(l)
}

### Data ingest ###

# Read in the bed files and format in single table
bedTemp <- read_tsv(args$bedFile2FP, 
                    col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH")) %>%
  select(-TRASH, -REF, -POOL)
bedRegions <- read_tsv(args$bedFile1FP, 
                       col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH")) %>%
  select(-TRASH, -REF, -POOL) %>%
  bind_rows(bedTemp) %>%
  arrange(START) %>%
  relocate(ORF)
print(bedRegions)

# Get a list of samples from directory names
# Start with a list of files 
pbFiles <- list.files(path = file.path(args$analysisDirFP, args$pacbamDir),
                      pattern = paste0("*", args$pacbamFileSuf),
                      full.names = TRUE,
                      recursive = TRUE)

# Read in PacBam output

### Process data ###

# Create list of sample IDs from file names
sampleIDs <- c()
for (f in 1:length(pbFiles)) {
  sampleIDs <- c(sampleIDs, str_replace(basename(dirname(pbFiles[f])), 
                                        paste0("-", args$runID), 
                                        ""))
}
# Add sample IDs to outList. Creates outList.
# outList is a list of CecretSamples. Access Sample ID using outList[[n]]@Sample.ID.
# CecretSample values correspond to ORFs. Data needed in the output table for each ORF are contained within the CecretORF objects in each CecretSample class slot.
uniqSampleIDs <- unique(sampleIDs)
outList <- list()
for (i in 1:length(uniqSampleIDs)) {
  outList <- list.append(outList, new("CecretSample", Sample.ID = uniqSampleIDs[i]))
}
print(outList)

# Loop to call functions and append data to output table.
# Start with a single test run
