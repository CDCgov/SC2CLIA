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
Usage: config.R -r <runID> -a <analysisDirFP> [-s <pacbamFileSuf> -b <bedFile1FP> -t <bedFile2FP> -p <pacbamDir> -m <minCov> -c <concensusDir> -f <consensusFileSuf>]
config.R (-v | --version)
config.R (-h | --help)
Options:
-r <runID> --runID=<runID>                                    Run ID; string
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>            Cecret output directory full path; string
-b <bedFile1FP> --bedFile1FP=<bedFile1FP>                     Bed file 1 with full path; string [default: ../configs/MN908947.3-ORFs.bed]
-t <bedFile2FP> --bedFile2FP=<bedFile2FP>                     Bed file 2 with full path; string [default: ../configs/MN908947.3-ORF7b.bed]
-p <pacbamDir> --pacbamDir=<pacbamDir>                        PacBam output directory name; string [default: pacbam_orfs]
-s <pacbamFileSuf> --pacbamFileSuf=<pacbamFileSuf>            PacBam output file suffic; string [default: .primertrim.sorted.pileup]
-m <minCov> --minCov=<minCov>                                 Minimum coverage threshold to call a position; integer [default: 30]
-c <consensusDir> --consensusDir=<consensusDir>               Consensus output directory name; string [default: consensus]
-f <consensusFileSuf> --consensusFileSuf=<consensusFileSuf>   Consensus file suffix; string [default: .consensus.fa]
-h --help                                                     Show this help and exit
-v --version                                                  Show version and exit"

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

indexFinder <- function(v, p) {
  # where v = vector to search
  # where p = pattern to find
  # returns index of matching item in string
  return(which(str_detect(v, p)))
}

testAndSlice <- function(v, b, o) {
  # where v = vector to slice
  # where b = bed file tibble
  # where o = target ORF
  orfStart <- b[indexFinder(b$ORF, o),]$START
  orfEnd <- b[indexFinder(b$ORF, o),]$END
  if (length(v) >= orfEnd) {
    return(v[orfStart:orfEnd])
  } else {
    return(NA_character_)
  }
}

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
  return(unlist(str_split(v[2], "")))
}

# Functions to subset data by regions in bedRegions
# Subset the consensus data
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

# Function(s) to calculate mean depth, %pos meeting min cov, #n, %n per region. 
# Calculate #N from consensus data for single ORF
nCounter <- function(v) {
  # where v = vector of sequence for single ORF, as generated by consensusToORFs()
  # returns integer
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
    return((n / l)*100)
  }
}

# Calculate length of ORF; handles NAs
orfLength <- function(v) {
  # where v is a vector of ORF sequence
  # returns length or NA as appropriate
  if (is.na(v) == FALSE) {
    return(length(v))
  } else {
    return(NA_real_)
  }
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

# Read in PacBam output

### Process data ###

# Create list of sample IDs from consensus file names
sampleIDs <- c()
for (f in 1:length(consensusFiles)) {
  sampleIDs <- c(sampleIDs, str_replace(basename(consensusFiles[f]), 
                                        paste0("-", args$runID, args$consensusFileSuf), 
                                        ""))
}
# Initialize outList. Add sample IDs to outList.
# outList is a list of CecretSamples. Access Sample ID using outList[[n]]@Sample.ID.
# CecretSample slots correspond to ORFs. Data needed in the output table for each ORF are contained within the CecretORF objects in each CecretSample class slot.
uniqSampleIDs <- unique(sampleIDs) # This serves as an index for outList.
outList <- list()
for (i in 1:length(uniqSampleIDs)) {
  outList <- list.append(outList, new("CecretSample", Sample.ID = uniqSampleIDs[i]))
}

# Loop to call functions and append data to outList.
for (s in 1:length(uniqSampleIDs)) {
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
  slot(outList[[s]]@ORF1ab, "Percent.Ns") <- nPercent(outList[[s]]@ORF1ab@Num.Ns, outList[[s]]@ORF1ab@Length)
  slot(outList[[s]]@S, "Percent.Ns") <- nPercent(outList[[s]]@S@Num.Ns, outList[[s]]@S@Length)
  slot(outList[[s]]@ORF3a, "Percent.Ns") <- nPercent(outList[[s]]@ORF3a@Num.Ns, outList[[s]]@ORF3a@Length)
  slot(outList[[s]]@E, "Percent.Ns") <- nPercent(outList[[s]]@E@Num.Ns, outList[[s]]@E@Length)
  slot(outList[[s]]@M, "Percent.Ns") <- nPercent(outList[[s]]@M@Num.Ns, outList[[s]]@M@Length)
  slot(outList[[s]]@ORF6, "Percent.Ns") <- nPercent(outList[[s]]@ORF6@Num.Ns, outList[[s]]@ORF6@Length)
  slot(outList[[s]]@ORF7a, "Percent.Ns") <- nPercent(outList[[s]]@ORF7a@Num.Ns, outList[[s]]@ORF7a@Length)
  slot(outList[[s]]@ORF7b, "Percent.Ns") <- nPercent(outList[[s]]@ORF7b@Num.Ns, outList[[s]]@ORF7b@Length)
  slot(outList[[s]]@ORF8, "Percent.Ns") <- nPercent(outList[[s]]@ORF8@Num.Ns, outList[[s]]@ORF8@Length)
  slot(outList[[s]]@N, "Percent.Ns") <- nPercent(outList[[s]]@N@Num.Ns, outList[[s]]@N@Length)
  slot(outList[[s]]@ORF10, "Percent.Ns") <- nPercent(outList[[s]]@ORF10@Num.Ns, outList[[s]]@ORF10@Length)
}

# Here we create the output table and write it to file.
outTable <- tibble()
for (sampleIndex in 1:length(outList)) {
  for (sampleSlotName in slotNames(outList[[sampleIndex]])) {
    if (sampleSlotName != "Sample.ID") {
      tempRow <- c(outList[[sampleIndex]]@Sample.ID, 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "ORF.ID"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Mean.Depth"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Length"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Num.Ns"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Num.Min.Cov"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Percent.Ns"), 
                   slot(slot(outList[[sampleIndex]], sampleSlotName), "Percent.Min.Cov"))
      outTable <- rbind(outTable, tempRow)
    }
  }
}
colnames(outTable) <- c("Sample.ID",
                        "ORF.ID",
                        "Mean.Depth",
                        "Length",
                        "Num.Ns",
                        "Num.Min.Cov",
                        "Percent.Ns",
                        "Percent.Min.Cov")
write_tsv(outTable, 
          file = file.path(args$analysisDirFP, args$pacbamDir, "orf_stats.tsv"), 
          col_names = TRUE)
write_file(toString(warnings(nwarnings = 10000)), file = file.path(args$analysisDirFP, "logs", "R_warnings_orf_stats.txt"))
