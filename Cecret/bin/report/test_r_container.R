#!/usr/bin/env Rscript

# Test if your R packages will all load
mypkgs <- c("remotes", "tidyverse", "formattable", "DT", "docopt", "kableExtra", "testthat", "knitr", "rmarkdown", "dygraphs", "tinytex")
for (p in mypkgs) {
  eval(bquote(library(.(p))))
}
sessionInfo()
quit()