# ampliconstats_dropout README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
samtools_ampliconstats_dropout channel, which holds the sample and its ampliconstats.txt (output from samtools ampliconstats)

## Function
This process calls amplicon_stat.py to parse the ampliconstats.txt file to print out the amplicon drop outs stats

## Outputs
amplicon drop outs stats text file per sample

## Dependencies
samtools_ampliconstats process

## Note
A amplicon_dropout_summary will be created, under which are all the resulting text files

## Contributing
Rong Jin