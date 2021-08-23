# SC2CLIA

A SARS-CoV-2 pipeline built on Dr. Erin Young's Cecret StaphB pipeline and adapted for CLIA reporting and validation

Active development by EDLB

## TOC
* [Description](#description)
* [Requirements](#requirements)
* [INSTALL](#install)
* [USAGE](#usage)
* [Main Components](#main-components)
* [NOTE](#note)
* [Contributing](#contributing)
* [Future Plans](#future-plans)
* [Resources](#resources)


## Description

Cecret is a workflow developed by Dr. Erin Young' for SARS-COV-2 sequencing with the [artic](https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html)/Illumina hybrid library prep workflow for MiSeq data with protocols [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bffyjjpw) and [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bfefjjbn). We adapted it for CDC-specific QA/QC metrics and CLIA reporting and validation



## Requirements

1. Python 3 or higher. Download python [here](https://www.python.org/downloads/). 

2. Nextflow version 20+ is required [here](https://www.nextflow.io/docs/latest/getstarted.html).  

3. [Singularity](https://singularity.lbl.gov/install-linux)  version 3.7 is recommended. run `singularity --version` in your terminal <br>
   ***Warning: version 3.5 does not work***

4. Cecret workflow installed.  Read more about Cecret [here](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev).



## INSTALL

(We haven't elaborated here because these instructions will change when we containerize the pipeline.)

1. Copy the Github repository to a folder  
`git clone https://github.com/cdcent/SC2CLIA.git` 

2. [Obtain the R Singularity container](R_Singularity_README.md) by downloading or building your own copy


## USAGE

1. Run the following script at your base folder(replace `data_folder` with the path to your data; r is for generating report files)  
 `./run_cecret.sh - d data_folder `  (there is an optional flag `-p` to apply a different profile(default to v3) in the config file)
 
## Main Components

#### original Cecret processes by Dr. Erin are:

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

#### EDLB custom NextFlow processes are:
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

#### Additional EDLB custom scripts:
- [Custom R Singularity container definition file](R_singularity_README.md) - building and using the custom Singularity container used to execute all R scripts in the pipeline
- [ORF statistics calculation scripts (R versions)](orf_table_README.md) - using and understanding the R scripts calculating ORF quality statistics for the pipeline
- [Reports](report_README.md) - configuring and interpreting the different reports generated by the pipeline

#### Reference documents
- [artic_V3_nCoV-2019.bed](../Cecret/configs/artic_V3_nCoV-2019.bed): Artic V3 primer scheme. [Source](https://github.com/artic-network/artic-ncov2019/blob/master/primer_schemes/nCoV-2019/V3/nCoV-2019.bed).
- [artic_v3_nCoV-2019.insert.even.bed](../Cecret/configs/artic_v3_nCoV-2019.insert.even.bed) and [artic_v3_nCoV-2019.insert.odd.bed](../Cecret/configs/artic_v3_nCoV-2019.insert.odd.bed): Artic V3 amplicon locations split across two BED files such that even and odd numbered amplicons are in different files. [Source](https://github.com/artic-network/artic-ncov2019/blob/master/primer_schemes/nCoV-2019/V3/nCoV-2019.insert.bed).
- [MN908947.3-ORF7b.bed](../Cecret/configs/MN908947.3-ORF7b.bed) and [MN908947.3-ORFs.bed](../Cecret/configs/MN908947.3-ORFs.bed): Open reading frame annotations for SARS-CoV-2. [Source](../Cecret/configs/MN908947.3.gff) was converted to a BED file. BED file was then split to avoid overlapping annotations in a single file.
- [MN908947.3.gff](../Cecret/configs/MN908947.3.gff) Open reading frame annotations for SARS-CoV-2. [Source](https://github.com/UPHL-BioNGS/Cecret/blob/master/configs/MN908947.3.gff).
- [MN908947.3.fasta](../Cecret/configs/MN908947.3.fasta). SARS-CoV-2 reference genome sequence. [Source](https://github.com/UPHL-BioNGS/Cecret/blob/master/configs/MN908947.3.fasta).
- [MN908947.3.fasta.fai](../Cecret/configs/MN908947.3.fasta.fai) Fasta index file.

## Note

1. running the above script will generate a folder 'Run_(current timestamp)' with all the resulting files/folders in it

2. the sample data in the `data_folder`should have a flat structure without being in additional sub-folders

## Contributing

(Note: this section might also change depending on how we package this.)


## Future Plans

We might plan to containerize this pipeline in the future.

## Resources

[Cecret](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev)
