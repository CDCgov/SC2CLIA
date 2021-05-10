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
Note that the Sample.Name column is repeated regularly to aid in readability. Numbers are appended to the ends of the repeated column headers.

| summary.txt column | index.html column | eLIMS report column | value description |
| --- | --- | --- | --- |
| sample_id | Sample.ID | not included | Sample ID fragment starting at beginning and going through first hyphen |
| not included | not included | CSID | |
| not included | not included | CUID | |
| sample | Sample.Name | not included | Full sample identifier |
| aligner_version | not included | not included | |
| ivar_version | not included | not included | |
| pangolin_lineage | Pangolin | Lineage | |
| pangolin_status | Pangolin.QC | not included | |
| nextclade_clade | NextClade | not included | |
| fastqc_raw_reads_1 | #FastQC.R1 | Total Reads | |
| fastqc_raw_reads_2 | #FastQC.R2 | not included | |
| seqyclean_pairs_kept_after_cleaning | #Seqyclean.Pairs | not included | |
| seqyclean_percent_kept_after_cleaning | %Seqyclean.Pairs | not included | |
| fastp_reads_passed | not included | not included | |
| depth_after_trimming | Depth.Post.Trim | Average Depth | |
| coverage_after_trimming | Coverage.Post.Trim | Percent Genome Coverage | |
| %_human_reads | %Human.Reads | not included | |
| %_SARS-COV-2_reads | %SC2.Reads | not included | |
| ivar_num_variants_identified | #iVar.Variants | not included | |
| bcftools_variants_identified | #BCFTools.Variants | not included | |
| bedtools_num_failed_amplicons | #BEDTools.Failed.Amps | not included | |
| samtools_num_failed_amplicons | SAMTools.Failed.Amps | not included | |
| num_N | #N | not included | |
| num_degenerage | #Degenerate | not included | |
| num_ACTG | #ACTG | not included | |
| num_total | #Total.Bases | not included | |
| Total_Reads_Analyzed | Total.Reads.Analyzed | Mapped Reads | |
| %_N | %N | not included | |
| ave_cov_depth | Mean.Cov.Depth | not included | |
| %_Reads_Matching_SC2_Ref | %Reads.Mapping.SC2 | not included | |
| vadr_status | Vadr | not included | |
| vdr_sample_orfshift | Vadr.All.ORF.Shift | not included | |
| vdr_sgene_orftshift | Vadr.S.ORF.Shift | not included | |
| S_aa_indels | AA.Changes.S | Spike Protein Substitutions | list of insertions, deletions, and substitions found in the amino acids reported for the S gene |
| len_largest_insertion | Length.Longest.Insert | not included | |
| len_largest_deletion | Length.Longest.Del | not included | |
| pangoLEARN_version | pangoLearn.v | pangoLEARN Version | |
| pangolin_subs | #Lineage.Subs | Number of Lineage-Defined Substitutions | |
| Percent.Mapped.Reads | Percent.Mapped.Reads | Percent Mapped Reads | Calculated as (Total Reads Analyzed / Total Reads)*100 |
| GenBank# | GenBank# | GenBank Accession # | |
| ORFs.Passing.QC | ORFs.Passing.QC | Open Reading Frames | a count of ORFs with >=95% coverage and mean depth of >=100x |
| Coverage.S | Coverage.S | S-gene Coverage | percentage of positions in the predicted S gene length that have any (even 1 read) sequencing data |
| Mean.Depth.S | Mean.Depth.S | not included | mean depth of coverage of sequencing across predicted S gene |
| Percent.Pos.Min.Cov.S | Percent.Pos.Min.Cov.S | not included | percentage of positions in the S gene that meet minimum coverage threshold |
| Percent.Ns.S | Percent.Ns.S | not included | percentage of Ns in the region of the consensus sequence for the S gene |

