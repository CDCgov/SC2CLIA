### Cecret Report README Stub

***

#### Requires
The Singularity container described in Cecret/configs/singularity-r.def. Currently all R-based scripts and versions.sh execute within this container from the outside. 
`singularity exec --bind /mnt,/path/to/host/directory/containing/all/files/required/for/analysis singularity_container_name.sif Rscript script_name.R <args>` Note the mount point in the host directory tree must include both the required scripts and the required input files.

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

The other output is SC2_Variant_WGS_Run_Summary.pdf located in the report directory. This file is for the CLIA technical supervisor to record official approval of the analysis output with an electronic signature. It is split up into two sections, eLIMS Fields and Other Dry Lab Fields.


### Summary Table Details
Note that the Sample.Name column is repeated regularly to aid in readability in the report documents. Numbers are appended to the ends of the repeated column headers.  

The table below provides details about each column found in four different output documents. 
* `summary.txt` is the primary summary output document from Cecret, and the name of the field in `summary.txt` is found under "summary.txt column" below.
* `index.html` is a lightly modified version of `summary.txt`. Fields may be removed in `index.html` relative to `summary.txt`, but there are no additional fields. Fields with pass/fail thresholds are visually coded to reflect their score. The name of the field is found under "index.html column" below.
* `push_to_elims.txt` and `SC2_Variant_WGS_Run_Summary.pdf` contain identical names for columns that they share, and those column names are listed under "eLIMS report column" below. `push_to_elims.txt` contains the subset of fields from `summary.txt` that are uploaded into eLIMS. `SC2_Variant_WGS_Run_Summary.pdf` is another copy of `summary.txt` with an electronic signature page for recording official CLIA approvals of the data. There are three tables in `SC2_Variant_WGS_Run_Summary.pdf`, "eLIMS Fields" for the fields that are entered into eLIMS, "Other QC Fields" for other QC data that is _not_ uploaded to eLIMS, and "Other Dry Lab Fields" for everything else that is in `summary.txt` but _not_ uploaded to eLIMS or used for CLIA QC.

| use | summary.txt column | index.html column | eLIMS report column | threshold | value description |
| --- | --- | --- | --- | --- | --- |
| not reported | sample_id | Sample.ID | not included | not null | Sample ID fragment starting at beginning and going through first hyphen |
| reported | not included | not included | CSID | not null | |
| reported | not included | not included | CUID | not null | |
| not reported | sample | Sample.Name | not included | not null | Full sample identifier |
| not reported | aligner_version | not included | not included | not null | |
| not reported | ivar_version | not included | not included | not null | |
| reported | pangolin_lineage | Pangolin | Lineage | not null | |
| QC | pangolin_status | Pangolin.QC | not included | passed | |
| not reported | nextclade_clade | NextClade | not included | | |
| QC | fastqc_raw_reads_1 | #FastQC.R1 | Total Reads | >=100,000 | |
| not reported | fastqc_raw_reads_2 | #FastQC.R2 | not included | >=100,00 | |
| not reported | seqyclean_pairs_kept_after_cleaning | #Seqyclean.Pairs | not included | | |
| not reported | seqyclean_percent_kept_after_cleaning | %Seqyclean.Pairs | not included | | |
| not reported | fastp_reads_passed | not included | not included | | |
| QC | depth_after_trimming | Depth.Post.Trim | Average Depth | >=100x | |
| QC | coverage_after_trimming | Coverage.Post.Trim | Percent Genome Coverage | >= 90% with SME discretion to go as low as 60% if mutations reported | |
| not reported | %_human_reads | %Human.Reads | not included | | |
| not reported | %_SARS-COV-2_reads | %SC2.Reads | not included | | |
| not reported | ivar_num_variants_identified | #iVar.Variants | not included | | |
| not reported | bcftools_variants_identified | #BCFTools.Variants | not included | | |
| not reported | bedtools_num_failed_amplicons | #BEDTools.Failed.Amps | not included | | |
| not reported | samtools_num_failed_amplicons | SAMTools.Failed.Amps | not included | | |
| not reported | num_N | #N | not included | | |
| not reported | num_degenerage | #Degenerate | not included | | |
| not reported | num_ACTG | #ACTG | not included | | |
| not reported | num_total | #Total.Bases | not included | | |
| not reported | Total_Reads_Analyzed | Total.Reads.Analyzed | Mapped Reads | 100,000 | |
| QC | %_N | %N | not included | <10% | |
| not reported | ave_cov_depth | Mean.Cov.Depth | not included | | |
| QC | %_Reads_Matching_SC2_Ref | %Reads.Mapping.SC2 | Percent Mapped Reads | >=65% | |
| not reported | vadr_status | Vadr | not included | | |
| not reported | vdr_sample_orfshift | Vadr.All.ORF.Shift | not included | | |
| QC | vdr_sgene_orftshift | Vadr.S.ORF.Shift | not included | false | |
| reported | S_aa_indels | AA.Changes.S | Spike Protein Substitutions | not null | list of insertions, deletions, and substitutions found in the amino acids reported for the S gene |
| not reported | len_largest_insertion | Length.Longest.Insert | not included | |
| not reported | len_largest_deletion | Length.Longest.Del | not included | |
| reported | pangoLEARN_version | pangoLearn.v | pangoLEARN Version | not null | |
| reported | pangolin_subs | #Lineage.Subs | Number of Lineage-Defined Substitutions | not null | |
| reported | GenBank# | GenBank# | GenBank Accession # | NA until # obtained | |
| QC | ORFs.Passing.QC | ORFs.Passing.QC | Open Reading Frames | >=10 | a count of ORFs with >=95% coverage and mean depth of >=100x |
| QC | Coverage.S | Coverage.S | S-gene Coverage | >= 95% | percentage of positions in the predicted S gene length that have any (even 1 read) sequencing data |
| not reported | Mean.Depth.S | Mean.Depth.S | not included | | mean depth of coverage of sequencing across predicted S gene |
| not reported | Percent.Pos.Min.Cov.S | Percent.Pos.Min.Cov.S | not included | | percentage of positions in the S gene that meet minimum coverage threshold |
| QC | Percent.Ns.S | Percent.Ns.S | not included | <10% | percentage of Ns in the region of the consensus sequence for the S gene |

