# nextcladeParse README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
nextclade_csv_out channel, which has the sample name and corresponding csv result file from nextclade

## Function
This process calls upon nextclade_aa_parser.py to parse the csv file generated by nextclade, to retrieve Spike Protein Substitutions information

## Outputs
nextclade_parsed_out channel, which has the sample name and the parsed aa INDEL results 

## Dependencies
nextclade process 

## Note

## Contributing
Sean Lucking