#!/usr/bin/Rscript

# Script version
ver <- "version 0.1\n"

# Load libraries
suppressMessages(library(docopt))
suppressMessages(library(testthat))
suppressMessages(library(rmarkdown))

# Parse the args with docopt (will always be character strings)
doc <- "Description: run this script to generate a report from Cecret pipeline outputs in HTML.

Author: A. Jo Williams-Newkirk at ***REMOVED***

Dependencies:
R packages: docopt, testthat, rmarkdown

Usage: config.R -r <runID> -a <analysisDirFP> -s <seqDirFP>
config.R (-v | --version)
config.R (-h | --help)

Options:
-r <runID> --runID=<runID>                            Sequencing run ID; string
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>    Cecret output directory full path; string
-s <seqDirFP> --seqDirFP=<seqDirFP>                   Full path to sequencing run directory; string
-h --help                                             Show this help and exit
-v --version                                          Show version and exit"

# Parse input args
args <- docopt(doc = doc, version = ver)

### To dos ###
# Change location of output files so they aren't rendered in bin/report to avoid multiple user collisions
# Test input args to ensure they match expected values
# Test that all *.Rmd files and multiQC report exist in expected locations
# Test versions.sh output to ensure created and not empty
# Add input args to specify file locations, eg. versions.sh, *.Rmd

# Set up the output directory
suppressWarnings(dir.create(file.path(args$analysisDirFP, "report")))
suppressWarnings(dir.create(file.path(args$analysisDirFP, "report", "subpages")))

# Cp multiqc output to report directory
# Note weirdness: on 4/18 I had a typo with a double / in the middle of the -a path when launching the script and it only failed on this step. WHY???
system2(command = "cp",
        args = c(file.path(args$analysisDirFP, "MultiQC", "multiqc_report.html"),
                 file.path(args$analysisDirFP, "report", "subpages")),
        wait = TRUE)

# Run versions.sh
system2(command = "./versions.sh",
        args = c(args$analysisDirFP),
        wait = TRUE)

# Parameters to pass to Rmd files
params <- list(runID = args$runID,
               analysisDirFP = args$analysisDirFP,
               seqDirFP = args$seqDirFP)

# Rmd files to render
rmdFiles <- c("about.Rmd", "index.Rmd", "runInfo.Rmd", "runQC.Rmd", "ampliconCov.Rmd")

# Do the rendering
lapply(rmdFiles, FUN = function(x) render(input = x, output_format = "html_document", params = params, output_dir = file.path(args$analysisDirFP, "report")))

# Move rendered files into single output directory
# system2(command = "mv",
#         args = c("*.html", paste(args$analysisDirFP, "report", sep = "/")),
#         wait = TRUE)
# system2(command = "mv",
#         args = c("ref_docs/*.html", paste(args$analysisDirFP, "report/ref_docs/", sep = "/")),
#         wait = TRUE)

