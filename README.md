# SC2CLIA

A SARS-CoV-2 pipeline built on Dr. Erin Young's Cecret StaphB pipeline and adapted for CLIA reporting and validation

Active development by EDLB

## TOC
* [Description](#description)
* [Requirements](#requirements)
* [INSTALL](#install)
* [USAGE](#usage)
* [NOTE](#note)
* [Contributing](#contributing)
* [Future Plans](#future-plans)
* [Resources](#resources)


## Description

Cecret is a workflow developed by Dr. Erin Young' for SARS-COV-2 sequencing with the [artic](https://artic.network/ncov-2019/ncov2019-bioinformatics-sop.html)/Illumina hybrid library prep workflow for MiSeq data with protocols [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bffyjjpw) and [here](https://www.protocols.io/view/sars-cov-2-sequencing-on-illumina-miseq-using-arti-bfefjjbn). We adapted it for CDC-specific QA/QC metrics and CLIA reporting and validation



## Requirements

1. Python 3 or higher. Download python [here](https://www.python.org/downloads/). 

2. Nextflow version 20+ is required [here](https://www.nextflow.io/docs/latest/getstarted.html).  

3. [Singularity](https://singularity.lbl.gov/install-linux) 

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

1. Run the following script at your base folder(replace `data_folder` with the path to your data; p is for pacbam; v is for vadr)  
 `./run_cecret.sh - d data_folder -p true(default false) -v true(default false)`  

## Note

1. running the above script will generate a folder 'Run_(current timestamp)' with all the resulting files/folders in it

2. the sample data in the `data_folder`should have a flat structure without being in additional sub-folders

## Contributing

(Note: this section might also change depending on how we package this.)


## Future Plans

We might plan to containerize this pipeline in the future.

## Resources

[Cecret](https://github.com/UPHL-BioNGS/Cecret/tree/erin-dev)

