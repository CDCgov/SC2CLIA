# mqc(MultiQC) README

## TOC
* [Inputs](#inputs)
* [Function](#function)
* [Outputs](#outputs)
* [Dependencies](#dependencies)
* [NOTE](#note)
* [Contributing](#contributing)

## Inputs
fastqc_results channel, which holds all files (html, zip) that reside in fastqc folder

## Function
This process calls on multiqc to compile a html report

## Outputs
1. a data channel which holds a multiqc_report.html file
2. a multiqc_data folder which holds all other files generated from multiqc call

## Dependencies
fastqc process

## Note
A MultiQC folder will be created, under which there are a multiqc_report.html file and a multiqc_data folder 

## Contributing
Rong Jin