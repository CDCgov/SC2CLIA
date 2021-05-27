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
R packages: docopt, testthat, tidyverse, rlist
Usage: orf_table.R -r <runID> -a <analysisDirFP> [-s <pacbamFileSuf> -b <bedFile1FP> -t <bedFile2FP> -p <pacbamDir> -m <minCov> -c <concensusDir> -f <consensusFileSuf> -d <meanDepthQC -l <covQC>]
config.R (-v | --version)
config.R (-h | --help)
Options:
-r <runID> --runID=<runID>                                    Run ID; string
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>            Cecret output directory full path; string
-b <bedFile1FP> --bedFile1FP=<bedFile1FP>                     Bed file 1 with full path; string [default: /opt/MN908947.3-ORFs.bed]
-t <bedFile2FP> --bedFile2FP=<bedFile2FP>                     Bed file 2 with full path; string [default: /opt/MN908947.3-ORF7b.bed]
-p <pacbamDir> --pacbamDir=<pacbamDir>                        PacBam output directory name; string [default: pacbam_orf]
-s <pacbamFileSuf> --pacbamFileSuf=<pacbamFileSuf>            PacBam output file suffic; string [default: .primertrim.sorted.pileup]
-m <minCov> --minCov=<minCov>                                 Minimum coverage threshold to call a position; integer [default: 30]
-c <consensusDir> --consensusDir=<consensusDir>               Consensus output directory name; string [default: consensus]
-f <consensusFileSuf> --consensusFileSuf=<consensusFileSuf>   Consensus file suffix; string [default: .consensus.fa]
-d <meanDepthQC> --meanDepthQC=<meanDepthQC>                  Mean depth threshold to pass basic QC; integer [default: 100]
-l <covQC> --covQC=<covQC>                                    Percentage coverage threshold to pass basic ORF QC; integer [default: 95]
-h --help                                                     Show this help and exit
-v --version                                                  Show version and exit"

args <- docopt(doc = doc, version = ver)

### Classes ###

# To do: write proper setter and getter functions for classes.
# CecretORF defines a class to hold relevant characteristics of a single ORF for a single sample
# May want to add sequence and coverage data directly to class and doing all calcs with internal class functions during refactoring.
setClass(Class = "CecretORF",
         slots = c(ORF.ID = "character",
                   Mean.Depth = "numeric",
                   Length = "numeric",
                   Num.Ns = "numeric",
                   Num.Pos.Min.Cov = "numeric",
                   Percent.Ns = "numeric",
                   Percent.Pos.Min.Cov = "numeric",
                   Coverage.ORF = "numeric"),
         prototype = list(ORF.ID = NA_character_,
                          Mean.Depth = NA_real_,
                          Length = NA_real_,
                          Num.Ns = NA_real_,
                          Num.Pos.Min.Cov = NA_real_,
                          Percent.Ns = NA_real_,
                          Percent.Pos.Min.Cov = NA_real_,
                          Coverage.ORF = NA_real_))
# CecretSample defines a class to hold a CecretORF object for each ORF in a single sample
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

# Find the index of the target string in a vector
indexFinder <- function(v, p) {
  # where v = vector to search
  # where p = pattern to find
  # returns index of matching item in vector
  return(which(str_detect(v, p)))
}

# Extract consensus sequence of target ORF from full sample consensus
testAndSlice <- function(v, b, o) {
  # where v = vector to slice
  # where b = bed file tibble
  # where o = target ORF
  # note: subtract 1 (by adding because coordinates) from start because bed file coordinates are written to start after this number and go through the end.
  orfStart <- b[indexFinder(b$ORF, o),]$START + 1
  orfEnd <- b[indexFinder(b$ORF, o),]$END
  if (length(v) >= orfEnd) {
    return(v[orfStart:orfEnd])
  } else {
    return(NA_character_)
  }
}

# Extract coverage data for target ORF from full sample coverage data
covTestAndSlice <- function(t, b, o) {
  # where t = tibble to slice
  # where b = bed file tibble
  # where o = target ORF
  # returns a vector of coverages for positions within the ORF
  # note: subtract 1 (by adding because coordinates) from start because bed file coordinates are written to start after this number and go through the end.
  orfStart <- b[indexFinder(b$ORF, o),]$START + 1
  orfEnd <- b[indexFinder(b$ORF, o),]$END
  outTable <- filter(t, between(Position, orfStart, orfEnd))
  if (length(outTable$Coverage) != 0) {
    return(outTable$Coverage)
  } else {
    return(NA_real_)
  }
}

# Read in consensus sequence for a single sample
consensusReader <- function(f) {
  # where f = single record consensus file, not wrapped, full path
  # returns 2 item vector.  1 = fasta line 1, 2 = fasta line 2
  consensusIn <- read_lines(f)
  return(consensusIn)
}

# Provides logic to determine which pacbam files to get for a given sample and initiates ingest
pbFileGetter <- function(v, i) {
  # where v is a vector of pacbam files
  # where i is a vector of indices for files to process in v
  # Note this function assumes the only possible numbers of pacbam files are 0, 1, or 2.
  # Returns NA or the formatted tibble of file contents from pbReader
  if (is.na(i[1]) == TRUE) {
    return(NA)
  } else {
    if (length(v) == 1) {
      return(pbReader(c(v[i[1]])))
    } else {
      return(pbReader(c(v[i[1]], v[i[2]]))) 
    }
  }
}

# Read in the pacbam files for 1 sample
pbReader <- function(v) {
  # where v is a vector of file names
  # returns a tibble sorted by nucleotide position containing coverage at each position
  # note that because of the way PacBam works, you will only have data for positions annotated in your bed file
  pbData <- tibble()
  for (f in v) {
    pbData <- bind_rows(pbData, read_tsv(file = f,
                                         col_names = TRUE, col_types = cols()))
  }
  pbData <- select(pbData, pos, cov) %>%
            arrange(pos) %>%
            distinct()
  colnames(pbData) <- c("Position", "Coverage")
  return(pbData)
}

# Formatting consensus data
consensusFormatter <- function(s, v) {
  # where v = 2 item list derived from consensusReader(). 1 = fasta line 1, 2 = fasta line 2
  # where s = Sample.ID record (string). 
  # To do: Write check later to confirm fasta line 1 contains Sample ID expected.
  # returns a vector where each letter in consensus is an item in the vector.
  return(unlist(str_split(v[2], "")))
}

# Subset the consensus data by regions in bedRegions
consensusToORFs <- function(v, b) {
  # where v = consensus vector from consensusFormatter().
  # where b = tibble like bedRegions (should always be bedRegions in this script)
  # returns a list of named vectors corresponding to ORFs in bedRegions (each item is ORFname = vector of sequence)
  orfList <- list()
  orfList <- list.append(orfList, 
                         ORF1ab = testAndSlice(v, b, "ORF1ab"),
                         S = testAndSlice(v, b, "S"),
                         ORF3a = testAndSlice(v, b, "ORF3a"),
                         E = testAndSlice(v, b, "E"),
                         M = testAndSlice(v, b, "M"),
                         ORF6 = testAndSlice(v, b, "ORF6"),
                         ORF7a = testAndSlice(v, b, "ORF7a"),
                         ORF7b = testAndSlice(v, b, "ORF7b"),
                         ORF8 = testAndSlice(v, b, "ORF8"),
                         N = testAndSlice(v, b, "N"),
                         ORF10 = testAndSlice(v, b, "ORF10"))
  return(orfList)
}

#Subset the coverage data by regions in bedRegions
covByORFs <- function(t, b) {
  # where t = tibble of coverage data for the sample
  # where b = bed tibble like bedRegions (should always be bedRegions in this script)
  # returns a list of named vectors corresponding to ORFs in bedRegions (each item is ORFname = vector of coverage for positions)
  covORFList <- list()
  if (!is.na(t) == TRUE) {
    covORFList <- list.append(covORFList, 
                             ORF1ab = covTestAndSlice(t, b, "ORF1ab"),
                             S = covTestAndSlice(t, b, "S"),
                             ORF3a = covTestAndSlice(t, b, "ORF3a"),
                             E = covTestAndSlice(t, b, "E"),
                             M = covTestAndSlice(t, b, "M"),
                             ORF6 = covTestAndSlice(t, b, "ORF6"),
                             ORF7a = covTestAndSlice(t, b, "ORF7a"),
                             ORF7b = covTestAndSlice(t, b, "ORF7b"),
                             ORF8 = covTestAndSlice(t, b, "ORF8"),
                             N = covTestAndSlice(t, b, "N"),
                             ORF10 = covTestAndSlice(t, b, "ORF10"))
  return(covORFList)
  } else {
    return(NA)
  }
}

# Calculate #N from consensus data for single ORF
nCounter <- function(v) {
  # where v = vector of sequence for single ORF, as generated by consensusToORFs()
  # returns integer count of Ns in vector
  # note: case sensitive
  if (is.na(v)) {
    return(NA_real_)
  } else {
    return(str_count(toString(v), "N"))
  }
}
# Calculate percent N in ORF from consensus data
nPercent <- function(n, l) {
  # where n = number Ns in ORF calculated by nCounter()
  # where 1 = length of ORF
  # returns percentage
  if (is.na(n) == TRUE || is.na(l) == TRUE) {
    return(NA_real_)
  } else {
    return(round((n / l)*100, digits = 1))
  }
}

# Calculate length of ORF
orfLength <- function(v) {
  # where v is a vector of ORF sequence
  # returns length or NA as appropriate
  if (is.na(v) == FALSE) {
    return(length(v))
  } else {
    return(NA_real_)
  }
}

# Calculate the percentage of positions in ORF with minimum coverage
percentPosMinCov <- function(n, l) {
  # where n is the number of positions meeting minimum coverage threshold
  # where l is the length of the ORF
  # returns percentage from n/l*100
  if (is.na(n) == FALSE && is.na(l) == FALSE) {
    return(round(n/l*100, digits = 1))
  } else {
    return(NA_real_)
  }
}

# Set Mean.Depth for all ORFs in sample
updateMeanDepth <- function(l, i, x) {
  # where l is a list of named vectors of coverage values for each position is assembly and each vector represents 1 ORF
  # where i is the index of the sample to process in l
  # where x is the list of CecretSamples to be updated
  # returns x, the updated list of CecretSamples
  # Note: uses length of ORF from pacbam data. Length reported out is derived from consensus data.
  # To do: cross-validate expected, consensus, and pacbam lengths and report QC
  if (is.na(l) == FALSE) {
    slot(x[[i]]@ORF1ab, "Mean.Depth") <- round(mean(l$ORF1ab), digits = 1)
    slot(x[[i]]@S, "Mean.Depth") <- round(mean(l$S), digits = 1)
    slot(x[[i]]@ORF3a, "Mean.Depth") <- round(mean(l$ORF3a), digits = 1)
    slot(x[[i]]@E, "Mean.Depth") <- round(mean(l$E), digits = 1)
    slot(x[[i]]@M, "Mean.Depth") <- round(mean(l$M), digits = 1)
    slot(x[[i]]@ORF6, "Mean.Depth") <- round(mean(l$ORF6), digits = 1)
    slot(x[[i]]@ORF7a, "Mean.Depth") <- round(mean(l$ORF7a), digits = 1)
    slot(x[[i]]@ORF7b, "Mean.Depth") <- round(mean(l$ORF7b), digits = 1)
    slot(x[[i]]@ORF8, "Mean.Depth") <- round(mean(l$ORF8), digits = 1)
    slot(x[[i]]@N, "Mean.Depth") <- round(mean(l$N), digits = 1)
    slot(x[[i]]@ORF10, "Mean.Depth") <- round(mean(l$ORF10), digits = 1)
  } else {
    slot(x[[i]]@ORF1ab, "Mean.Depth") <- NA_real_
    slot(x[[i]]@S, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF3a, "Mean.Depth") <- NA_real_
    slot(x[[i]]@E, "Mean.Depth") <- NA_real_
    slot(x[[i]]@M, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF6, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF7a, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF7b, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF8, "Mean.Depth") <- NA_real_
    slot(x[[i]]@N, "Mean.Depth") <- NA_real_
    slot(x[[i]]@ORF10, "Mean.Depth") <- NA_real_
  }
  return(x)
}

# Calculate and set Num.Pos.Min.Cov for all ORFs in sample
updateMinCov <- function(l, i, x, t) {
  # where l is a list of named vectors of coverage values for each position is assembly and each vector represents 1 ORF
  # where i is the index of the sample to process in l
  # where x is the list of CecretSamples to be updated
  # where t is the minimum coverage threshold
  # returns x, the updated list of CecretSamples
  if (is.na(l) == FALSE) {
    slot(x[[i]]@ORF1ab, "Num.Pos.Min.Cov") <- sum(l$ORF1ab >= t)
    slot(x[[i]]@S, "Num.Pos.Min.Cov") <- sum(l$S >= t)
    slot(x[[i]]@ORF3a, "Num.Pos.Min.Cov") <- sum(l$ORF3a >= t)
    slot(x[[i]]@E, "Num.Pos.Min.Cov") <- sum(l$E >= t)
    slot(x[[i]]@M, "Num.Pos.Min.Cov") <- sum(l$M >= t)
    slot(x[[i]]@ORF6, "Num.Pos.Min.Cov") <- sum(l$ORF6 >= t)
    slot(x[[i]]@ORF7a, "Num.Pos.Min.Cov") <- sum(l$ORF7a >= t)
    slot(x[[i]]@ORF7b, "Num.Pos.Min.Cov") <- sum(l$ORF7b >= t)
    slot(x[[i]]@ORF8, "Num.Pos.Min.Cov") <- sum(l$ORF8 >= t)
    slot(x[[i]]@N, "Num.Pos.Min.Cov") <- sum(l$N >= t)
    slot(x[[i]]@ORF10, "Num.Pos.Min.Cov") <- sum(l$ORF10 >= t)
  } else {
    slot(x[[i]]@ORF1ab, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@S, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF3a, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@E, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@M, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF6, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF7a, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF7b, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF8, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@N, "Num.Pos.Min.Cov") <- NA_real_
    slot(x[[i]]@ORF10, "Num.Pos.Min.Cov") <- NA_real_
  }
  return(x)
}

# Set Percent.Pos.Min.Cov for all ORFs in sample
updatePercPosMinCov <- function(l, i) {
  # where l is list of CecretSample objects
  # where i is index of target sample in object list
  # returns updated list of CecretSample objects
  slot(l[[i]]@ORF1ab, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF1ab, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF1ab, "Length"))
  slot(l[[i]]@S, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@S, "Num.Pos.Min.Cov"), slot(l[[i]]@S, "Length"))
  slot(l[[i]]@ORF3a, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF3a, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF3a, "Length"))
  slot(l[[i]]@E, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@E, "Num.Pos.Min.Cov"), slot(l[[i]]@E, "Length"))
  slot(l[[i]]@M, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@M, "Num.Pos.Min.Cov"), slot(l[[i]]@M, "Length"))
  slot(l[[i]]@ORF6, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF6, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF6, "Length"))
  slot(l[[i]]@ORF7a, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF7a, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF7a, "Length"))
  slot(l[[i]]@ORF7b, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF7b, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF7b, "Length"))
  slot(l[[i]]@ORF8, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF8, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF8, "Length"))
  slot(l[[i]]@N, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@N, "Num.Pos.Min.Cov"), slot(l[[i]]@N, "Length"))
  slot(l[[i]]@ORF10, "Percent.Pos.Min.Cov") <- percentPosMinCov(slot(l[[i]]@ORF10, "Num.Pos.Min.Cov"), slot(l[[i]]@ORF10, "Length"))
  return(l)
}

# Calculate and set Coverage.ORF for all ORFs in sample
updateCovORF <- function(l, i, x, t, b) {
  # where l is a list of named vectors of coverage values for each position is assembly and each vector represents 1 ORF
  # where i is the index of the sample to process in l
  # where x is the list of CecretSamples to be updated
  # where t is the minimum coverage threshold
  # where b is the bedRegions tibble
  # returns x, the updated list of CecretSamples
  if (is.na(l) == FALSE) {
    slot(x[[i]]@ORF1ab, "Coverage.ORF") <- round(sum(l$ORF1ab >= t) / b[indexFinder(b$ORF, "ORF1ab"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@S, "Coverage.ORF") <- round(sum(l$S >= t) / b[indexFinder(b$ORF, "S"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF3a, "Coverage.ORF") <- round(sum(l$ORF3a >= t) / b[indexFinder(b$ORF, "ORF3a"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@E, "Coverage.ORF") <- round(sum(l$E >= t) / b[indexFinder(b$ORF, "E"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@M, "Coverage.ORF") <- round(sum(l$M >= t) / b[indexFinder(b$ORF, "M"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF6, "Coverage.ORF") <- round(sum(l$ORF6 >= t) / b[indexFinder(b$ORF, "ORF6"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF7a, "Coverage.ORF") <- round(sum(l$ORF7a >= t) / b[indexFinder(b$ORF, "ORF7a"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF7b, "Coverage.ORF") <- round(sum(l$ORF7b >= t) / b[indexFinder(b$ORF, "ORF7b"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF8, "Coverage.ORF") <- round(sum(l$ORF8 >= t) / b[indexFinder(b$ORF, "ORF8"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@N, "Coverage.ORF") <- round(sum(l$N >= t) / b[indexFinder(b$ORF, "N"),]$LENGTH * 100, digits = 1)
    slot(x[[i]]@ORF10, "Coverage.ORF") <- round(sum(l$ORF10 >= t) / b[indexFinder(b$ORF, "ORF10"),]$LENGTH * 100, digits = 1)
  } else {
    slot(x[[i]]@ORF1ab, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@S, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF3a, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@E, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@M, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF6, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF7a, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF7b, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF8, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@N, "Coverage.ORF") <- NA_real_
    slot(x[[i]]@ORF10, "Coverage.ORF") <- NA_real_
  }
  return(x)
}

### One-time non-function data ingest ###

# Read in the bed files and format in single table
bedTemp <- read_tsv(args$bedFile2FP, 
                    col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH"), col_types = cols()) %>%
  select(-TRASH, -REF, -POOL)
bedRegions <- read_tsv(args$bedFile1FP, 
                       col_names = c("REF", "START", "END", "ORF", "POOL", "TRASH"), col_types = cols()) %>%
  select(-TRASH, -REF, -POOL) %>%
  bind_rows(bedTemp) %>%
  arrange(START) %>%
  relocate(ORF) %>%
  mutate(LENGTH = END - START)

# Get a list of consensus files
consensusFiles <- list.files(path = file.path(args$analysisDirFP, args$consensusDir),
                             pattern = "*.fa",
                             full.names = TRUE,
                             recursive = TRUE)

# Get a list of pacbam files 
pbFiles <- list.files(path = file.path(args$analysisDirFP, args$pacbamDir),
                      pattern = paste0("*", args$pacbamFileSuf),
                      full.names = TRUE,
                      recursive = TRUE)

### Process data ###

# Create list of sample IDs from consensus file names
sampleIDs <- c()
for (f in 1:length(consensusFiles)) {
  sampleIDs <- c(sampleIDs, str_replace(basename(consensusFiles[f]), 
                                        paste0("-", args$runID, args$consensusFileSuf), 
                                        ""))
}
# Quick and dirty fix for the lack of a run ID in Undetermined leaving the consensusFileSuf on Undecided.
sampleIDs <- str_replace(sampleIDs, args$consensusFileSuf, "")

# Initialize outList. Add sample IDs to outList.
# outList is a list of CecretSamples. Access Sample ID using outList[[n]]@Sample.ID.
# CecretSample slots correspond to ORFs. Data needed in the output tables for each ORF are contained within the CecretORF objects in each CecretSample class slot.
uniqSampleIDs <- unique(sampleIDs) # This serves as an index for outList.
outList <- list()
for (i in 1:length(uniqSampleIDs)) {
  outList <- list.append(outList, new("CecretSample", Sample.ID = uniqSampleIDs[i]))
}

# Loop to call functions and append data to outList.
for (s in 1:length(uniqSampleIDs)) {
  # This first large block handles everything derived from consensus files
  conFileIndex <- which(str_detect(consensusFiles, uniqSampleIDs[s]))
  conFileVec <- consensusReader(consensusFiles[conFileIndex])
  conVec <- consensusFormatter(uniqSampleIDs[s], conFileVec)
  orfList <- consensusToORFs(conVec, bedRegions)
  # Num.Ns
  slot(outList[[s]]@ORF1ab, "Num.Ns") <- nCounter(orfList$ORF1ab)
  slot(outList[[s]]@S, "Num.Ns") <- nCounter(orfList$S)
  slot(outList[[s]]@ORF3a, "Num.Ns") <- nCounter(orfList$ORF3a)
  slot(outList[[s]]@E, "Num.Ns") <- nCounter(orfList$E)
  slot(outList[[s]]@M, "Num.Ns") <- nCounter(orfList$M)
  slot(outList[[s]]@ORF6, "Num.Ns") <- nCounter(orfList$ORF6)
  slot(outList[[s]]@ORF7a, "Num.Ns") <- nCounter(orfList$ORF7a)
  slot(outList[[s]]@ORF7b, "Num.Ns") <- nCounter(orfList$ORF7b)
  slot(outList[[s]]@ORF8, "Num.Ns") <- nCounter(orfList$ORF8)
  slot(outList[[s]]@N, "Num.Ns") <- nCounter(orfList$N)
  slot(outList[[s]]@ORF10, "Num.Ns") <- nCounter(orfList$ORF10)
  # Length
  slot(outList[[s]]@ORF1ab, "Length") <- orfLength(orfList$ORF1ab)
  slot(outList[[s]]@S, "Length") <- orfLength(orfList$S)
  slot(outList[[s]]@ORF3a, "Length") <- orfLength(orfList$ORF3a)
  slot(outList[[s]]@E, "Length") <- orfLength(orfList$E)
  slot(outList[[s]]@M, "Length") <- orfLength(orfList$M)
  slot(outList[[s]]@ORF6, "Length") <- orfLength(orfList$ORF6)
  slot(outList[[s]]@ORF7a, "Length") <- orfLength(orfList$ORF7a)
  slot(outList[[s]]@ORF7b, "Length") <- orfLength(orfList$ORF7b)
  slot(outList[[s]]@ORF8, "Length") <- orfLength(orfList$ORF8)
  slot(outList[[s]]@N, "Length") <- orfLength(orfList$N)
  slot(outList[[s]]@ORF10, "Length") <- orfLength(orfList$ORF10)
  # Percent.Ns
  slot(outList[[s]]@ORF1ab, "Percent.Ns") <- nPercent(outList[[s]]@ORF1ab@Num.Ns, 
                                                      outList[[s]]@ORF1ab@Length)
  slot(outList[[s]]@S, "Percent.Ns") <- nPercent(outList[[s]]@S@Num.Ns, 
                                                 outList[[s]]@S@Length)
  slot(outList[[s]]@ORF3a, "Percent.Ns") <- nPercent(outList[[s]]@ORF3a@Num.Ns, 
                                                     outList[[s]]@ORF3a@Length)
  slot(outList[[s]]@E, "Percent.Ns") <- nPercent(outList[[s]]@E@Num.Ns, 
                                                 outList[[s]]@E@Length)
  slot(outList[[s]]@M, "Percent.Ns") <- nPercent(outList[[s]]@M@Num.Ns, 
                                                 outList[[s]]@M@Length)
  slot(outList[[s]]@ORF6, "Percent.Ns") <- nPercent(outList[[s]]@ORF6@Num.Ns, 
                                                    outList[[s]]@ORF6@Length)
  slot(outList[[s]]@ORF7a, "Percent.Ns") <- nPercent(outList[[s]]@ORF7a@Num.Ns, 
                                                     outList[[s]]@ORF7a@Length)
  slot(outList[[s]]@ORF7b, "Percent.Ns") <- nPercent(outList[[s]]@ORF7b@Num.Ns, 
                                                     outList[[s]]@ORF7b@Length)
  slot(outList[[s]]@ORF8, "Percent.Ns") <- nPercent(outList[[s]]@ORF8@Num.Ns, 
                                                    outList[[s]]@ORF8@Length)
  slot(outList[[s]]@N, "Percent.Ns") <- nPercent(outList[[s]]@N@Num.Ns, 
                                                 outList[[s]]@N@Length)
  slot(outList[[s]]@ORF10, "Percent.Ns") <- nPercent(outList[[s]]@ORF10@Num.Ns, 
                                                     outList[[s]]@ORF10@Length)
  # Second large block handles things derived from PacBam output.
  pbFileIndex <- which(str_detect(pbFiles, uniqSampleIDs[s]))
  pbTable <- pbFileGetter(pbFiles, pbFileIndex)
  covORFList <- covByORFs(pbTable, bedRegions)
  # Mean.Depth
  # Note: uses length of ORF from pacbam data. Length reported out is derived from consensus data.
  outList <- updateMeanDepth(covORFList, s, outList)
  # Num.Pos.Min.Cov
  outList <- updateMinCov(covORFList, s, outList, as.numeric(args$minCov))
  # Percent.Pos.Min.Cov
  outList <- updatePercPosMinCov(outList, s)
  # Coverage.ORF
  outList <- updateCovORF(covORFList, s, outList, 1, bedRegions)
}

# Here we create the output tables and write them to file.
# outTable is the more detailed report
outTable <- tibble()
for (sampleIndex in 1:length(outList)) {
  for (sampleSlotName in slotNames(outList[[sampleIndex]])) {
    if (sampleSlotName != "Sample.ID") {
      tempRow <- c(outList[[sampleIndex]]@Sample.ID, 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "ORF.ID"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Mean.Depth"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Length"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Num.Ns"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Num.Pos.Min.Cov"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Percent.Ns"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Percent.Pos.Min.Cov"),
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Coverage.ORF"))
      outTable <- rbind(outTable, tempRow)
      # Note: R is coercing all data types into character during this process. And I hate it.
    }
  }
}

# Detailed table formatting
colnames(outTable) <- c("Sample.ID",
                        "ORF.ID",
                        "Mean.Depth",
                        "Length",
                        "Num.Ns",
                        "Num.Pos.Min.Cov",
                        "Percent.Ns",
                        "Percent.Pos.Min.Cov",
                        "Coverage.ORF")
outTable <- select(outTable, Sample.ID, ORF.ID, Length, Coverage.ORF, 
                   Mean.Depth, Num.Pos.Min.Cov, Percent.Pos.Min.Cov, 
                   Num.Ns, Percent.Ns) %>%
            mutate(QC = case_when(
                          as.numeric(Mean.Depth) >= as.numeric(args$meanDepthQC) & as.numeric(Coverage.ORF) >= as.numeric(args$covQC) ~ "PASS",
                          TRUE ~ "FAIL"))

# outTableSummary a summary table derived from outTable that gets added to summary.txt eventually.
outTableSummaryA <- group_by(outTable, Sample.ID) %>%
                   summarise(ORFs.Passing.QC = sum(QC == "PASS"))
outTableSummaryB <- filter(outTable, ORF.ID == "S") %>%
                    select(Sample.ID, 
                           Coverage.ORF, 
                           Mean.Depth, 
                           Percent.Pos.Min.Cov, 
                           Percent.Ns) %>%
                    rename(Coverage.S = Coverage.ORF, 
                           Mean.Depth.S = Mean.Depth, 
                           Percent.Pos.Min.Cov.S = Percent.Pos.Min.Cov, 
                           Percent.Ns.S = Percent.Ns)
outTableSummary <- left_join(outTableSummaryA, outTableSummaryB, by = "Sample.ID")

# Write out files
write_tsv(outTable, 
          file = file.path(args$analysisDirFP, args$pacbamDir, "orf_stats.tsv"), 
          col_names = TRUE)
write_tsv(outTableSummary, 
          file = file.path(args$analysisDirFP, args$pacbamDir, "orf_stats_summary.tsv"), 
          col_names = TRUE)
write_file(paste0("###### new run ######\n", toString(warnings(nwarnings = 10000))), file = file.path(args$analysisDirFP, "logs", "R_warnings_orf_stats.txt"))
