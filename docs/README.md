# SC2CLIA

A SARS-CoV-2 Nextflow pipeline for Clinical Laboratories Improvements Amendments (CLIA) compliant variant calling and spike protein substitution prediction with additional tools for quality control, CLIA-ready reports, and consensus sequence uploads to NCBI. 

## TOC
* [Description](#description)
* [Requirements](#requirements)
* [Install](#install)
* [Usage](#usage)
* [Main Components](#main-components)
* [Note](#note)
* [Contributing](#contributing)
* [Future Plans](#future-plans)
* [Resources](#resources)
* [Notices](#notices)


## Description

SC2CLIA Cecret is a CLIA compliance ready SARS-CoV-2 analysis workflow developed bioinformaticians from the [Enterics Diseases Laboratory Branch](https://www.cdc.gov/ncezid/dfwed/edlb/index.html) at the [Centers for Disease Control and Prevention](https://www.cdc/gov) with assistance from CDC's [Respiratory Viruses Branch](https://www.cdc.gov/ncird/dvd.html). It adds CDC-specific QA/QC metrics, CLIA-ready reports, database storage stubs, and consensus sequence uploads for NCBI to the [Cecret](https://github.com/UPHL-BioNGS/Cecret) SARS-CoV-2 workflow developed by Dr. Erin Young at the [Utah Public Health Laboratories](https://uphl.utah.gov/).

The SC2CLIA Cecret pipeline is designed to analyze SARS-CoV-2 sequencing with the [ARTIC](https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html)/Illumina hybrid library prep workflow for MiSeq data with protocols [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bffyjjpw) and [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bfefjjbn). 



## Requirements

1. Python 3 or higher. Download python [here](https://www.python.org/downloads/). 

2. Nextflow version 20+ is required [here](https://www.nextflow.io/docs/latest/getstarted.html).  

3. [Singularity](https://singularity.lbl.gov/install-linux)  version 3.7 is recommended. run `singularity --version` in your terminal <br>
   ***Warning: version 3.5 does not work***
   
   ***Warning: Singularity will use the default tmp dirtory for temporary storage, enough space is required. You might want to set SINGULARITY_TMPDIR to a directory which has enough space***

4. Cecret workflow installed.  Read more about Cecret [here](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev).



## Install

1. Copy the Github repository to a folder  
`git clone https://github.com/cdcent/SC2CLIA.git` 

2. [Obtain the R Singularity container](R_Singularity_README.md) by downloading or building your own copy  
[image url in settings.ini file](../Cecret/configs/internal/settings.ini)   -   note if you just want to use the default version, the pipeline will automatically download the R Singularity container

3. Make sure to update configuration files with your own custom paths in [config folder](README.md#configs-folder) - see Config folder below

### [WARNING]

- ***You will need to prepare your own version of report.pdf and report.tex (and put them under Cecret/configs/internal/). Otherwise the 2nd to last 'report' process will throw out an error***.
- ***In Cecret/configs/internal/singularity.config, line #109, we currently set errorStrategy to ‘ignore’ for now, it better to be set to ‘retry’ once the above issue is fixed***.
- ***In Cecret/configs/internal/singularity.config, you will need to fill in the path for ‘kraken2_db’ and ‘bbmap’, although bbmap process is turned off by default, and kraken part will just not run without the db***. 
- ***In Cecret/Cecret_alltools.nf, line #2102, you will need to set MP= to the correct path (which is the mount point for R container, usually we set it to top level directory)***

 


## Usage

1. Run the following script at your base folder(replace `data_folder` with the path to your data; r is for generating report files)  
 `./run_cecret.sh - d data_folder `    
 (there is an optional flag `-p` to apply a different profile (default to v3) in the config file)  
 (there is an optional flag `-b` to turn on bbmap process: map filtered reads to human genome GRCh38)  
 
## Main Components

#### Original Cecret Nextflow processes include:

- [seqyclean](https://github.com/ibest/seqyclean) - for cleaning reads
- [fastp](https://github.com/OpenGene/fastp) - for cleaning reads ; optional, faster alternative to seqyclean
- [bwa](http://bio-bwa.sourceforge.net/) - for aligning reads to the reference
- [minimap2](https://github.com/lh3/minimap2) - an alternative to bwa
- [ivar](https://andersen-lab.github.io/ivar/html/manualpage.html) - calling variants and creating a consensus fasta; optional primer trimmer
- [samtools](http://www.htslib.org/) - for QC metrics and sorting; optional primer trimmer; optional converting bam to fastq files
- [fastqc](https://github.com/s-andrews/FastQC) - for QC metrics
- [bedtools](https://bedtools.readthedocs.io/en/latest/) - for depth estimation over amplicons
- [kraken2](https://ccb.jhu.edu/software/kraken2/) - for read classification
- [pangolin](https://github.com/cov-lineages/pangolin) - for lineage classification
- [nextclade](https://clades.nextstrain.org/) - for clade classification
- [mafft](https://mafft.cbrc.jp/alignment/software/) - for multiple sequence alignment (optional, relatedness must be set to "true")
- [snp-dists](https://github.com/tseemann/snp-dists) - for relatedness determination (optional, relatedness must be set to "true")
- [iqtree](http://www.iqtree.org/) - for phylogenetic tree generation (optional, relatedness must be set to "true")
- [bamsnap](https://github.com/parklab/bamsnap) - to create images of SNPs
- [filter](../Cecret/Cecret_alltools.nf) - to filter out human DNA from the reads

#### SC2CLIA Cecret Nextflow processes include:
- [vadr](https://github.com/ncbi/vadr) - for annotating fastas like NCBI (different than Erin's version)
- [pacbam_amplicons](https://bitbucket.org/CibioBCG/pacbam/src/master) - for characterization of genomic regions and single nucleotide positions (for amplicons)
- [pacbam_orfs](https://bitbucket.org/CibioBCG/pacbam/src/master) - for characterization of genomic regions and single nucleotide positions (for ORFs)
- [nextcladeParse](nextcladeParse_README.md) - for parsing nextclade csv file and generating aa change stats
- [ivar_vcf](ivar_vcf_README.md) - for converting ivar_variants tsv file into standard vcf file
- [coverage_depth (bwa,samtools)](coverage_depth_README.md) - for calculating average read coverage over non-N consensus positions
- [sc2ref](sc2ref_README.md) - for calculating percentage of reads passing QC that align to reference
- [ncbi_upload](../Cecret/Cecret_alltools.nf) - for ncbi GenBank submission
- [mqc](mqc_README.md) - for generating MultiQC report
- [largest_indel](largest_indel_README.md) - for calculating largest INDEL length
- [ampliconstats_dropout](ampliconstats_dropout_README.md) - for generating amplicon drop outs stats
- [bbmap](bbmap_README.md) - for mapping filtered reads to human genome GRCh38

#### Additional SC2CLIA R and Python scripts:
- [Custom R Singularity container definition file](R_singularity_README.md) - building and using the custom Singularity container used to execute all R scripts in the pipeline
- [ORF statistics calculation scripts (R versions)](orf_table_README.md) - using and understanding the R scripts calculating ORF quality statistics for the pipeline
- [Reports](report_README.md) - configuring and interpreting the different reports generated by the pipeline

#### Configs folder
The configs folder contains some important reference files, configuration files and some static information files.

- [reference files](README.md#reference-documents) - see Reference documents below
- [containers_fixedversion_hash.config](containers_fixedversion_hash_config_README.md) - a central place for holding container information for all processes
- author_template.csv - used by ncbi_upload module
- submission_template.csv - used by ncbi_upload module
- [internal folder](../Cecret/configs/internal) - We use this folder to hold any path/domain specific files/variables.
   - [settings.ini](settings_ini_README.md) - general purpose configuration file for the CDC SC2CLIA pipeline
   - [singularity.config](singularity_config_README.md) - custom configuration file for the CDC CLIA version of Cecret

#### Reference documents
- [artic_V3_nCoV-2019.bed](../Cecret/configs/artic_V3_nCoV-2019.bed): Artic V3 primer scheme. [Source](https://github.com/artic-network/artic-ncov2019/blob/master/primer_schemes/nCoV-2019/V3/nCoV-2019.bed).
- [artic_v3_nCoV-2019.insert.even.bed](../Cecret/configs/artic_v3_nCoV-2019.insert.even.bed) and [artic_v3_nCoV-2019.insert.odd.bed](../Cecret/configs/artic_v3_nCoV-2019.insert.odd.bed): Artic V3 amplicon locations split across two BED files such that even and odd numbered amplicons are in different files. [Source](https://github.com/artic-network/artic-ncov2019/blob/master/primer_schemes/nCoV-2019/V3/nCoV-2019.insert.bed).
- [MN908947.3-ORF7b.bed](../Cecret/configs/MN908947.3-ORF7b.bed) and [MN908947.3-ORFs.bed](../Cecret/configs/MN908947.3-ORFs.bed): Open reading frame annotations for SARS-CoV-2. [Source](../Cecret/configs/MN908947.3.gff) was converted to a BED file. BED file was then split to avoid overlapping annotations in a single file.
- [MN908947.3.gff](../Cecret/configs/MN908947.3.gff) Open reading frame annotations for SARS-CoV-2. [Source](https://github.com/UPHL-BioNGS/Cecret/blob/master/configs/MN908947.3.gff).
- [MN908947.3.fasta](../Cecret/configs/MN908947.3.fasta). SARS-CoV-2 reference genome sequence. [Source](https://github.com/UPHL-BioNGS/Cecret/blob/master/configs/MN908947.3.fasta).
- [MN908947.3.fasta.fai](../Cecret/configs/MN908947.3.fasta.fai) Fasta index file.

## Note

1. Running the above script will generate a folder 'Run_<current-timestamp>_<runID>' with all the resulting analysis, output, and QC files/folders in it

2. The fastq data for all samples in an analysis should be in a single input `data_folder`. 


## Contributing


## Future Plans

We might plan to containerize this pipeline in the future.

## Resources

[Cecret](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev)
  
## Notices

### Public Domain Notice
This repository constitutes a work of the United States Government and is not
subject to domestic copyright protection under 17 USC § 105. This repository is in
the public domain within the United States, and copyright and related rights in
the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
All contributions to this repository will be released under the CC0 dedication. By
submitting a pull request you are agreeing to comply with this waiver of
copyright interest.

### Privacy Notice
This repository contains only non-sensitive, publicly available data and
information. All material and community participation is covered by the
[Disclaimer](https://github.com/CDCgov/template/blob/master/DISCLAIMER.md)
and [Code of Conduct](https://github.com/CDCgov/template/blob/master/code-of-conduct.md).
For more information about CDC's privacy policy, please visit [http://www.cdc.gov/other/privacy.html](https://www.cdc.gov/other/privacy.html).

### Contributing Notice
Anyone is encouraged to contribute to the repository by [forking](https://help.github.com/articles/fork-a-repo)
and submitting a pull request. (If you are new to GitHub, you might start with a
[basic tutorial](https://help.github.com/articles/set-up-git).) By contributing
to this project, you grant a world-wide, royalty-free, perpetual, irrevocable,
non-exclusive, transferable license to all users under the terms of the
[Apache Software License v2](http://www.apache.org/licenses/LICENSE-2.0.html) or
later.

All comments, messages, pull requests, and other submissions received through
CDC including this GitHub page may be subject to applicable federal law, including but not limited to the Federal Records Act, and may be archived. Learn more at [http://www.cdc.gov/other/privacy.html](http://www.cdc.gov/other/privacy.html).

### Records Management Notice
This repository is not a source of government records, but is a copy to increase
collaboration and collaborative potential. All government records will be
published through the [CDC web site](http://www.cdc.gov).
