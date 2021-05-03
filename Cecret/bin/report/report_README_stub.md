### Cecret Report README Stub

***

#### Use
To view script options: `Rscript config.R --help`

#### Outputs
All html outputs are placed in the Cecret analysis directory under report by default. Standard outputs include:
* index.html: an easier to read version of summary.txt from the Cecret analysis output.
* runInfo.html: an easier to read version of SampleSheet.csv in the sequencer output directory.
* runQC.html: links to MultiQC report and displays insert size histograms for each sample.
* ampliconCov.html: displays and links to detailed amplicon coverage analysis for each sample.
* sGene.html: currently only stub for future development.
* about.html: lists output directories and the version of component software used to generate them.

<br>

The other output is summary_signature.pdf located in the report directory. This file is for the CLIA technical supervisor to record official approval of the analysis output.


### Summary Table Details
Note that the Sample.Name column is repeated regularly to aid in readability. Numbers are appended to the ends of the repeated column headers.

| summary.txt column | index.html column | value description |
| --- | --- | --- |
| sample_id | Sample.ID | Sample ID fragment starting at beginning and going through first hyphen |
| sample | Sample.Name | Full sample identifier |
| aligner_version | not included | |
| ivar_version | not included | |
| pangolin_lineage | Pangolin | |
| pangolin_status | Pangolin.QC | |
| nextclade_clade | NextClade | |
| fastqc_raw_reads_1 | #FastQC.R1 | |
| fastqc_raw_reads_2 | #FastQC.R2 | |
| seqyclean_pairs_kept_after_cleaning | #Seqyclean.Pairs | |
| seqyclean_percent_kept_after_cleaning | %Seqyclean.Pairs | |
| fastp_reads_passed | not included | |
| depth_after_trimming | Depth.Post.Trim | |
| coverage_after_trimming | Coverage.Post.Trim | | 
| %_human_reads | %Human.Reads | |
| %_SARS-COV-2_reads | %SC2.Reads | |
| ivar_num_variants_identified | #iVar.Variants | |
| bcftools_variants_identified | #BCFTools.Variants | |
| bedtools_num_failed_amplicons | #BEDTools.Failed.Amps | |
| samtools_num_failed_amplicons | SAMTools.Failed.Amps | |
| num_N | #N | |
| num_degenerage | #Degenerate | |
| num_ACTG | #ACTG | |
|num_total | #Total.Bases | |
| Total_Reads_Analyzed | Total.Reads.Analyzed | |
| %_N | %N | |
| ave_cov_depth | Mean.Cov.Depth | |
| %_Reads_Matching_SC2_Ref | %Reads.Mapping.SC2 | |
| vadr_status | Vadr | |
| vdr_sample_orfshift | Vadr.All.ORF.Shift | |
| vdr_sgene_orftshift | Vadr.S.ORF.Shift | |
| len_largest_insertion | Length.Longest.Insert | |
| len_largest_deletion | Length.Longest.Del | |
| ORFs.Passing.QC | ORFs.Passing.QC | a count of ORFs with >=95% coverage and mean depth of >=100x |
| Coverage.S | Coverage.S | percentage of positions in the predicted S gene length that have any (even 1 read) sequencing data |
| Mean.Depth.S | Mean.Depth.S | mean depth of coverage of sequencing across predicted S gene |
| Percent.Pos.Min.Cov.S | Percent.Pos.Min.Cov.S | percentage of positions in the S gene that meet minimum coverage threshold |
| Percent.Ns.S | Percent.Ns.S | percentage of Ns in the region of the consensus sequence for the S gene |
