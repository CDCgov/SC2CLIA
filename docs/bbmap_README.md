# bbmap README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
val(sample), file(reads), file(unpaired_reads) from filtered_reads channel.

## Function
This process executes bbmap.sh and bbduk.sh (for weeding out low-complexity sequences) to map the filtered reads to human genome GRCh38

## Outputs
a bbmap folder with a bbmap_result.txt file

## Dependencies 
filter process

## Note
The process could be time-consuming. It is turned off by default. It can be turned on by using the -b flag with the run_cecret script


## Contributing
Rong Jin