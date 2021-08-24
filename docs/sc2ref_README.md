# SC2Ref_matched_reads README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
pre_SC2Ref_matched_reads channel, which holds the sample name, cleaned fastq reads file and sorted bam file

## Function
This process executes samtools stats call to calculate the percentage of reads aligning to reference in the total reads that pass QC

## Outputs
a data channel which has the sample name and  value of the percentage of reads aligning to reference in the total reads that pass QC

## Dependencies
seqyclean process and sort process

## Note
In case there is 0 reads which pass QC, the percentage value will be -1


## Contributing
Rong Jin