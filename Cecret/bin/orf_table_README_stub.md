### orf_table.R README Stub

***

#### Use
To view script options: `Rscript orf_table.R --help`

#### Outputs
All data outputs are placed in the Cecret analysis directory under pacbam_orfs by default.  

orf_stats.tsv is a nine column tab-delimited table.
* Sample.ID: sample identifier derived from the input consensus file names.
* ORF.ID: SC2 ORF identifier.
* Length: length of ORF as sequenced. Derived from consensus input files. Calculated by slicing the consensus sequence at the predicted location of the ORF according to input bed files. Performs no checking to see if sequence is actual or correct ORF. Returns NA if consensus is too short to provide complete ORF at predicted location.
* Coverage.ORF: percentage of positions in the predicted ORF length that have any (even 1 read) sequencing data. Derived from PacBam input files. Calculated as number of positions with coverage >= 1 divided by the length of the predicted ORF and converted to percentage. Returns NA if PacBam coverage data is not reported (presumably because of low sequencing quality).
* Mean.Depth: mean depth of coverage of sequencing across predicted ORF. Derived from PacBam input files. Calculated as sum of coverages for each position divided by the length of the ORF in the PacBam data. Returns NA if PacBam coverage data is not reported (presumably because of low sequencing quality).
* Num.Pos.Min.Cov: number of positions in the ORF meeting minimum coverage threshold. Threshold defaults to 30. Derived from PacBam input files. Returns NA if PacBam coverage data is not reported (presumably because of low sequencing quality).
* Percent.Pos.Min.Cov: percentage of positions in the ORF that meet minimum coverage threshold. Threshold defaults to 30. Derived from PacBam input files. Calculated as Num.Pos.Min.Cov divided by Length and converted to percentage. Returns NA if either Num.Pos.Min.Cov or Length are NA.
* Num.Ns: number of Ns in the consensus sequence for the ORF. Derived from consensus input files. Calculated by counting Ns in the region of the consensus predicted to contain the target ORF according to the bed file. Returns NA if the consensus is too short to provide complete ORF at predicted location.
* Percent.Ns: percentage of Ns in the region of the consensus sequence for the ORF. Derived from consensus input files. Calculated as Num.Ns / Length and converted to percentage. Returns NA if the consensus is too short to provide complete ORF at predicted location.
* QC: PASS/FAIL for all ORFs. Requires ORF to pass on both covQC and meanDepthQC thresholds provided in script args; default to 95% and 100x, respectively.  

orf_stats_summary.tsv is a six column tab-delimited table derived from data in orf_stats.tsv. It is intended to be directly appended to the summary.txt output table.
* Sample.ID: same as above.
* ORFs.Passing.QC: a count of the ORFs with "PASS" as a value in the QC column of orf_stats.tsv for each sample.
* Coverage.S: same as Coverage.ORF but for S gene only.
* Mean.Depth.S: same as Mean.Depth but for S gene only.
* Percent.Pos.Min.Cov.S: same as Percent.Pos.Min.Cov but for S gene only.
* Percent.Ns.S: same as Percent.Ns but for S gene only.  

R_warnings_orf_stats.txt can be found in the logs directory of the Cecret analysis directory.