#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be ran in $CECRET_BASE or your local git repo folder

usage() { echo "Usage: $0 <-d  specify data folder> " 1>&2; exit 1; }

while getopts "d:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
		*) usage ;;
	esac
done

if [ -z "${DATA}" ]; then
    usage
fi

if [ ! -d "Cecret" ]; then
    echo "Error!  Can't find Cecret directory";
    exit 1;
fi


CECRET_BASE= ***replace with your own path here***
#CECRET_NEXTFLOW=$CECRET_BASE/Cecret/Cecret_alltools.nf
CECRET_NEXTFLOW=$PWD/Cecret/Cecret_alltools.nf
#CONFIG=$CECRET_BASE/Cecret/configs/singularity.config
CONFIG=$PWD/Cecret/configs/singularity.config

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
#OUTDIR=$CECRET_BASE/Run_$current_time
OUTDIR=$PWD/Run_$current_time

$CECRET_BASE/nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR --kraken2 true --kraken2_db=$CECRET_BASE/kraken2_db

# -- the following scripts are moved to nextflow workflow instead --

# this file might be confusing, it is the same as the 'summary.txt' under each Run folder
#rm run_results.txt

# parse the vcf files and add len_largest_deletion, len_largest_insertion to the result file
#python3 vcf_parser.py -d $OUTDIR/bcftools_variants -o $OUTDIR/summary.txt

# parse the ampliconstats.txt files and add create a folder to hold amplicon dropout info
#python3 amplicon_stat.py -d $OUTDIR/samtools_ampliconstats -o $OUTDIR/amplicon_dropout_summary
