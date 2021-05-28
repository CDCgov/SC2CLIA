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
# Test input args to ensure they match expected values
# Test that all *.Rmd files and multiQC report exist in expected locations
# Test versions.sh output to ensure created and not empty
# Add input args to specify file locations, eg. versions.sh, *.Rmd

# Set up the output directory
suppressWarnings(dir.create(file.path(args$analysisDirFP, "report")))
suppressWarnings(dir.create(file.path(args$analysisDirFP, "report", "subpages")))
suppressWarnings(dir.create(file.path(args$analysisDirFP, "report", "temp")))

# Cp multiqc output to report directory
# Note weirdness: on 4/18 I had a typo with a double / in the middle of the -a path when launching the script and it only failed on this step. WHY???
system2(command = "cp",
        args = c(file.path(args$analysisDirFP, "MultiQC", "multiqc_report.html"),
                 file.path(args$analysisDirFP, "report", "subpages")),
        wait = TRUE)

# Run versions.sh
system2(command = "/opt/versions.sh",
        args = c(args$analysisDirFP),
        wait = TRUE)

# Parameters to pass to Rmd files
params <- list(runID = args$runID,
               analysisDirFP = args$analysisDirFP,
               seqDirFP = args$seqDirFP)

# Rmd files to render
rmdFiles <- c("about.Rmd", "sGene.Rmd", "index.Rmd", "runInfo.Rmd", "runQC.Rmd", "ampliconCov.Rmd")
moreRmdFiles <- c("ampliconDetailTemplate.Rmd", "clia_summary.Rmd")

# As of writing, Rmd files cannot be knitted from a non-writeable location. 
lapply(rmdFiles, FUN = function(x) file.copy(file.path("/opt", x), file.path(args$analysisDirFP, "report", "temp"), overwrite = TRUE))
lapply(moreRmdFiles, FUN = function(x) file.copy(file.path("/opt", x), file.path(args$analysisDirFP, "report", "temp"), overwrite = TRUE))

# Do the rendering
lapply(rmdFiles, FUN = function(x) render(input = file.path(args$analysisDirFP, "report", "temp", x), output_format = "html_document", params = params, output_dir = file.path(args$analysisDirFP, "report")))

# Render the CLIA summary-signature page as PDF
render(input = file.path(args$analysisDirFP, "report", "temp", "clia_summary.Rmd"), 
       output_format = "pdf_document", 
       params = params, 
       output_dir = file.path(args$analysisDirFP, "report"),
       envir = new.env())

# Merge CLIA pdf with template digital signature page
system2(command = "pdftk",
        args = c(file.path(args$analysisDirFP, "report", "clia_summary.pdf"), 
                 file.path("/opt/clia_sig_page_digsig.pdf"),
                 "cat",
                 "output",
                 file.path(args$analysisDirFP, "report", "SC2_Variant_WGS_Run_Summary.pdf")),
        wait = TRUE)

# Clean up intermediate files
if (file.exists(file.path(args$analysisDirFP, "report", "clia_summary.pdf"))) {
  system2(command = "rm",
          args = c(file.path(args$analysisDirFP, "report", "clia_summary.pdf")),
          wait = TRUE)
}
if (dir.exists(file.path(args$analysisDirFP, "report", "temp"))) {
  unlink(file.path(args$analysisDirFP, "report", "temp"), recursive = TRUE)
}