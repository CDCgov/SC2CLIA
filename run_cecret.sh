#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be ran in $CECRET_BASE or your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder -p true  
# -p is optioal to turn on pacbam process

usage() { echo "Usage: $0 <-d  specify data folder> <-p  true:false flag to run pacbam> <-v  true:false flag to run vadr>" 1>&2; exit 1; }

PB=true
VADR=true
while getopts "d:p:v:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
        p) PB=${OPTARG} ;;
		v) VADR=${OPTARG} ;;
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
OUTDIR=$PWD/Run\_$current_time\_$(basename $DATA)

$CECRET_BASE/nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR \
							--kraken2 true --kraken2_db=$CECRET_BASE/kraken2_db \
							--pacbam $PB --vadr $VADR

# Stops the ^H character from being printed after running Nextflow
stty erase ^H

# -- the following scripts are moved to nextflow workflow instead --

# this file might be confusing, it is the same as the 'summary.txt' under each Run folder
#rm run_results.txt

# parse the vcf files and add len_largest_deletion, len_largest_insertion to the result file
#python3 vcf_parser.py -d $OUTDIR/bcftools_variants -o $OUTDIR/summary.txt

# parse the ampliconstats.txt files and add create a folder to hold amplicon dropout info
#python3 amplicon_stat.py -d $OUTDIR/samtools_ampliconstats -o $OUTDIR/amplicon_dropout_summary

echo running R scripts to generate reports ...

SC2-Seq-CLIA_mnt= ***replace with your own path here***
R_IMG=$CECRET_BASE/SINGULARITY_CACHE/singularity-r.sif
R_script=$CECRET_BASE/Cecret/bin/report/config.R


cd Cecret/bin/report

# singularity exec -B  ***replace with your own path here***
# 				-a /mnt/Run\_$current_time\_$(basename $DATA) \
# 				-r $(basename $DATA) \
# 				-s /mnt/runs > /dev/null 

singularity exec -B $SC2-Seq-CLIA_mnt:/mnt $R_IMG Rscript $R_script \
				 -a /mnt/cecret_test_prod/Run\_$current_time\_$(basename $DATA) \
				 -r $(basename $DATA) \
				 -s $SC2-Seq-CLIA_mnt/runs/$(basename $DATA) > /dev/null
				 # note it will fail for run folder like this: 
				 #  ***replace with your own path here***

echo Done !
