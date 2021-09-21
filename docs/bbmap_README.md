# bbmap README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
token from ncbi_upload_results channel, signaling all the reads are available to process

## Function
This process executes bbwrap.sh and bbduk.sh (for weeding out low-complexity sequences) to map the filtered reads to human genome GRCh38

## Outputs
a bbmap folder with a bbmap_result.txt file will be created and placed under the filter folder

## Dependencies 

## Note
The process could be time-consuming. It is turned off by default. It can be turned on by using the -b flag with the run_cecret script


## Contributing
Rong Jin