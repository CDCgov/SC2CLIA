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

2. Build the R Singularity container  
`sudo singularity build Cecret/configs/singularity-r.sif Cecret/configs/singularity-r.def`  
Or without sudo access try [remote option](https://cloud.sylabs.io/builder).  

3. Test the R image (should output R session info without errors)  
`singularity exec Cecret/configs/singularity-r.sif Rscript Cecret/bin/report/test_r_container.Rscript`

## USAGE

1. Run the following script at your base folder(replace `data_folder` with the path to your data; r is for generating report files)  
 `./run_cecret.sh - d data_folder `  (there is an optional flag `-r false(default true)` if you want to turn it off)
 
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

#### EDLB custom processes are:
- [vadr](https://github.com/ncbi/vadr) - for annotating fastas like NCBI (different than Erin's version)
- [pacbam_amplicons](https://bitbucket.org/CibioBCG/pacbam/src/master) - for characterization of genomic regions and single nucleotide positions (for amplicons)
- [pacbam_orfs](https://bitbucket.org/CibioBCG/pacbam/src/master) - for characterization of genomic regions and single nucleotide positions (for ORFs)
- [nextcladeParse](https://clades.nextstrain.org/) - for parsing nextclade csv file and generating aa change stats
- [ivar_vcf](https://andersen-lab.github.io/ivar/html/manualpage.html) - for converting ivar_variants tsv file into standard vcf file
- [coverage_depth (bwa,samtools)](https://github.com/cdcent/SC2CLIA/blob/master/Cecret/Cecret_alltools.nf) - for calculating average read coverage over non-N consensus positions
- [sc2ref](https://github.com/cdcent/SC2CLIA/blob/master/Cecret/Cecret_alltools.nf) - for calculating percentage of reads passing QC that align to reference
- [ncbi_upload](https://github.com/cdcent/SC2CLIA/blob/master/Cecret/Cecret_alltools.nf) - for ncbi GenBank submission
- [mqc](https://github.com/ewels/MultiQC) - for generating MultiQC report
- [largest_indel](https://github.com/cdcent/SC2CLIA/blob/master/Cecret/Cecret_alltools.nf) - for calculating largest INDEL length
- [ampliconstats_dropout](https://github.com/cdcent/SC2CLIA/blob/master/Cecret/Cecret_alltools.nf) - for generating amplicon drop outs stats


## Note

1. running the above script will generate a folder 'Run_(current timestamp)' with all the resulting files/folders in it

2. the sample data in the `data_folder`should have a flat structure without being in additional sub-folders

## Contributing

(Note: this section might also change depending on how we package this.)


## Future Plans

We might plan to containerize this pipeline in the future.

## Resources

[Cecret](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev)

