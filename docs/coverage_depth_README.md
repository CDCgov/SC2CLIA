# coverage_depth (bwa,samtools) README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
pre_aocd_bwa channel, which has the sample name, cleaned fastq reads file and consensus fasta file

## Function
This process (actually 2 processes) executes bwa and samtools calls to calculate the average coverage depth per sample

## Outputs
a data channel which has the sample name and the calculated average coverage depth value

## Dependencies
seqyclean process and ivar_consensus process

## Note
There are actually 2 processes (coverage_depth_bwa, and coverage_depth_samtools). This is due to:
1. One process can only use one container image, but we need to use both bwa and samtools tools
2. Utilize parallelisation by splitting the whole process into 2 sub-processes.

## Contributing
Rong Jin