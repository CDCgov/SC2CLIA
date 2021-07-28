### Cecret Report README Stub

***

#### Requires
The Singularity container described in Cecret/configs/singularity-r.def. As of container version 2.0, all R-based scripts and versions.sh are included in this container and execute within it except for a few user-configurable files.  
`singularity --bind /mnt,<hostMntPt> run --app report <singularity_container_name.sif> <runID> <analysisDirFP> <seqDirFP>`  
Note that the mount point in the host directory tree must be high enough to include all required input files and output locations below it.  

#### Configuration

##### Customizing Report Headers and Footers for CLIA
To customize the PDF that serves as the official record of the run and is signed by the CLIA Technical Supervisor, you must modify one file `clia_headers_template.tex` found in SC2/Cecret/bin/report.  
<br>
Open the file in a text editor and scroll to the bottom.  
* To modify the report title in the page headers, edit the following line. The existing header reads "SARS-CoV-2 Variant Whole Genome Sequencing Run Summary". `\chead{\textbf{SARS-CoV-2 Variant Whole Genome Sequencing Run Summary}}`
* By default each page will be numbered in the lower right corner of the header, but since the signature sheet is rendered separately from the report, the signature page will always be numbered 1 even though it appears at the end of the final output PDF. You can resolve this by removing the line `\rhead{\thepage}` from the .tex file before rendering the signature page (usually performed only once on initial set up of the pipeline) and rendering the signature page without a page number, then putting the line back in before running the pipeline. This will result in a correctly numbered report with an unnumbered signature page at the end.
* To customize the version number of your document in the footer, replace the "#" in the following line with the desired version identifier. `\cfoot{\textbf{Ver. No.} #}`
* To customize the document identifier number in the footer, replace the "#" in the following line with the desired identifier. `\lfoot{\textbf{Doc. No.} #}`
* To customize the effective date in the footer, modify the placeholder date of 01/01/1900 in the following line. `\rfoot{\textbf{Effective Date:} 01/01/1900}`  
<br>
Once modifications are complete, save the file as `clia_headers.tex` in the same directory as the template (i.e. SC2/Cecret/bin/report).

##### Rendering the CLIA Signature Page Template
The CLIA signature page template file `clia_sig_page.Rmd` found in SC2/Cecret/bin/report must be manually rendered to create a PDF before running the pipeline. This PDF is reused by all subsequent analysis runs of the pipeline by appending it to the PDF of results tables outputted by each run.  
<br>
To render this page, we recommend you first see the instructions in the above section regarding the customization of the page headers and footers. Once customization is complete, launch the container `sc2clia-cecret-r:version#.sif` in the directory SC2/SINGULARITY-CACHE. Note that you must perform the first run of the pipeline to trigger the download of the Singularity image from the third party repository or build the image from the source file SC2/Cecret/configs/singularity-r.def before it will be available. Assuming you have downloaded the image through the pipeline, navigate to the directory Cecret/SINGULARITY-CACHE and run the command `singularity exec --bind /mnt,<hostMntPt> singularity-r-v-2.1.sif Rscript ../Cecret/bin/report/render_clia_sig.R`. The PDF will automatically render as `clia_sig.pdf` in SC2/Cecret/bin/report. Run command with `-h` at the end to see script help documentation.
<br>
Alternatively, if you have a reasonably modern version of R installed locally, you can render the file using that install instead of the Singularity image by running `Rscript Cecret/bin/report/render_clia_sig.R` from the SC2 directory.  
<br>
If you wish to keep your entire records system digital for CLIA, we recommend you use a program such as Adobe Acrobat Pro to create fillable fields on the clia_sig.pdf file before running the full pipeline. 

#### Use
To view script options: `singularity run-help --app report <singularity-container-name.sif>`

#### Outputs
All html outputs are placed in the Cecret analysis directory under report by default. Standard outputs include:
* index.html: an easier to read version of summary.txt from the Cecret analysis output.
* runInfo.html: an easier to read version of SampleSheet.csv in the sequencer output directory.
* runQC.html: links to MultiQC report and displays insert size histograms for each sample.
* ampliconCov.html: displays and links to detailed amplicon coverage analysis for each sample.
* sGene.html: currently only stub for future development.
* about.html: lists output directories and the version of component software used to generate them.

<br>

The other output is SC2_Variant_WGS_Run_Summary.pdf located in the report directory. This file is for the CLIA technical supervisor to record official approval of the analysis output with an electronic signature. It is split into three sections, eLIMS Fields, Other QC Fields, and Other Dry Lab Fields.

### Summary Table Details
Note that the Sample.Name column is repeated regularly to aid in readability in the report documents. Numbers are appended to the ends of the repeated column headers.  

The table below provides details about each column found in four different output documents. 
* `summary.txt` is the primary summary output document from Cecret, and the name of the field in `summary.txt` is found under "summary.txt column" below.
* `index.html` is a lightly modified version of `summary.txt`. Fields may be removed in `index.html` relative to `summary.txt`, but there are no additional fields. Fields with pass/fail thresholds are visually coded to reflect their score. The name of the field is found under "index.html column" below.
* `push_to_elims.txt` and `SC2_Variant_WGS_Run_Summary.pdf` contain identical names for columns that they share, and those column names are listed under "eLIMS report column" below. `push_to_elims.txt` contains the subset of fields from `summary.txt` that are uploaded into eLIMS. `SC2_Variant_WGS_Run_Summary.pdf` is another copy of `summary.txt` with an electronic signature page for recording official CLIA approvals of the data. There are three tables in `SC2_Variant_WGS_Run_Summary.pdf`, "eLIMS Fields" for the fields that are entered into eLIMS, "Other QC Fields" for other QC data that is _not_ uploaded to eLIMS, and "Other Dry Lab Fields" for everything else that is in `summary.txt` but _not_ uploaded to eLIMS or used for CLIA QC.  

The "use" column indicates whether a row is reported in eLIMS, not reported in eLIMS, or is an official CLIA QC metric that is reported (QC-R) or not reported (QC-NR).

| use | summary.txt column | index.html column | eLIMS report column | threshold | value description |
| --- | --- | --- | --- | --- | --- |
| not reported | sample_id | Sample.ID | not included | not null | Sample ID fragment starting at beginning and going through first hyphen |
| reported | not included | not included | CSID | not null | |
| reported | not included | not included | CUID | not null | |
| not reported | sample | Sample.Name | not included | not null | Full sample identifier |
| not reported | aligner_version | not included | not included | not null | |
| not reported | ivar_version | not included | not included | not null | |
| reported | pangolin_lineage | Pangolin | Lineage | not null | |
| QC-NR | pangolin_status | Pangolin.QC | not included | passed | |
| not reported | nextclade_clade | NextClade | not included | | |
| QC-R | fastqc_raw_reads_1 | #FastQC.R1 | Total Reads | >=100,000 | |
| not reported | fastqc_raw_reads_2 | #FastQC.R2 | not included | >=100,00 | |
| not reported | seqyclean_pairs_kept_after_cleaning | #Seqyclean.Pairs | not included | | |
| not reported | seqyclean_percent_kept_after_cleaning | %Seqyclean.Pairs | not included | | |
| not reported | fastp_reads_passed | not included | not included | | |
| QC-R | depth_after_trimming | Depth.Post.Trim | Average Depth | >=100x | |
| QC-R | coverage_after_trimming | Coverage.Post.Trim | Percent Genome Coverage | >= 90% with SME discretion to go as low as 60% if mutations reported | |
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
| not reported | Total_Reads_Analyzed | Total.Reads.Analyzed | not included | | |
| QC-NR | %_N | %N | not included | <10% | |
| not reported | ave_cov_depth | Mean.Cov.Depth | not included | | |
| QC-R | %_Reads_Matching_SC2_Ref | %Reads.Mapping.SC2 | Percent Mapped Reads | >=65% | |
| not reported | vadr_status | Vadr | not included | | |
| not reported | vdr_sample_orfshift | Vadr.All.ORF.Shift | not included | | |
| QC-NR | vdr_sgene_orftshift | Vadr.S.ORF.Shift | Frameshifts | false | |
| reported | S_aa_indels | AA.Changes.S | Spike Protein Substitutions | not null | list of insertions, deletions, and substitutions found in the amino acids reported for the S gene |
| not reported | len_largest_insertion | Length.Longest.Insert | not included | |
| not reported | len_largest_deletion | Length.Longest.Del | not included | |
| reported | pangoLEARN_version | pangoLearn.v | pangoLEARN Version | not null | |
| reported | pangolin_subs | #Lineage.Subs | Number of Lineage-Defined Substitutions | not null | |
| reported | GenBank# | GenBank# | GenBank Accession # | NA until # obtained | |
| QC-R | ORFs.Passing.QC | ORFs.Passing.QC | Open Reading Frames | >=10 | a count of ORFs with >=95% coverage and mean depth of >=100x |
| QC-R | Coverage.S | Coverage.S | S-gene Coverage | >= 95% | percentage of positions in the predicted S gene length that have any (even 1 read) sequencing data |
| not reported | Mean.Depth.S | Mean.Depth.S | not included | | mean depth of coverage of sequencing across predicted S gene |
| not reported | Percent.Pos.Min.Cov.S | Percent.Pos.Min.Cov.S | not included | | percentage of positions in the S gene that meet minimum coverage threshold |
| QC-NR | Percent.Ns.S | Percent.Ns.S | not included | <10% | percentage of Ns in the region of the consensus sequence for the S gene |

