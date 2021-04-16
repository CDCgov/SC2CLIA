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
R packages: docopt, testthat

Usage: config.R -r <runID> -a <analysisDirFP> -s <seqDirFP>
config.R (-v | --version)
config.R (-h | --help)

Options:
-r <runID> --runID=<runID>                            Sequencing run ID; string
-a <analysisDirFP> --analysisDirFP=<analysisDirFP>    Cecret output directory full path; string
-s <seqDirFP> --seqDirFP=<seqDirFP>                   Full path to sequencing run directory; string
-h --help                                             Show this help and exit
-v --version                                          Show version and exit"

args <- docopt(doc = doc, version = ver)

# Run bash script to generate list of component versions
# print(args$analysisDirFP)
# if (isTRUE(file.exists("../versions.sh"))) {
#   print("found versions")
# } else {
#   print("cannot find versions")
# }

system2(command = "../versions.sh",
        args = c(args$analysisDirFP),
        wait = TRUE)
# tryCatch(
#   expr = { 
#     test_that(desc = "versions.sh ran successfully",
#               code = {
#               expect_true(file.exists(paste0(args$analysisDirFP, "/versions.txt")))
#               expect_that(file.size(paste0(args$analysisDirFP, "/versions.txt")) > 0)
#           })
#   },
#   error = function(e){
#     print(e)
#     print("versions.sh did not execute successfully.")
#     print(paste0("Could not find: ", paste0(args$analysisDirFP, "/versions.txt"), " or file size was 0"))
#     stop()
#   }
# )

# Parameters to pass to Rmd files
params <- list(runID = args$runID,
               analysisDirFP = args$analysisDirFP,
               seqDirFP = args$seqDirFP)

# Rmd files to render
rmdFiles <- c("about.Rmd", "index.Rmd", "runInfo.Rmd", "runQC.Rmd", "ampliconCov.Rmd")
lapply(rmdFiles, FUN = function(x) render(input = x, output_format = "html_document", params = params))

# Move rendered files into single output directory
system2(command = "mv",
        args = c("*.html", paste(args$analysisDirFP, "report", sep = "/")),
        wait = TRUE)
system2(command = "mv",
        args = c("ref_docs/*.html", paste(args$analysisDirFP, "report/ref_docs/", sep = "/")),
        wait = TRUE)
# Cp multiqc output to report directory
system2(command = "cp",
        args = c(paste(args$analysisDirFP, "MultiQC/multiqc_report.html", sep = "/"),
                 paste(args$analysisDirFP, "report", sep = "/")),
        wait = TRUE)
