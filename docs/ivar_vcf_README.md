# ivar_vcf README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
ivar_variant_vcf channel, which has the sample name and corresponding sample variants tsv file

## Function
This process calls upon ivar_variants_to_vcf.py to convert ivar_variants tsv files into standard vcf files

## Outputs
a data channel which has the sample name and the sample variants vcf file 

## Dependencies
ivar_variants process 

## Note
A ivar_vcf folder will be created, under which are all sample vcf files

## Contributing
Rong Jin