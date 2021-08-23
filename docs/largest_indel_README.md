# largest_indel README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
ivar_vcf_indel channel, which holds the sample and its vcf file

## Function
This process calls vcf_parser_refactor_nf.py to calculate the largest length of insertion and deletion per sample

## Outputs
a data channel which has the sample name and value of the largest length of insertion and deletion (concatenated as a string)

## Dependencies
ivar_vcf process

## Note

## Contributing
Rong Jin