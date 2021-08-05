#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be run in your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder

usage() { echo "Usage: $0 <-d  specify data folder>" 1>&2; exit 1; }

while getopts "d:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
		*) usage ;;
	esac
done

# Display help if no arguments
if [ -z "${DATA}" ]; then
    usage
fi

# Exit if Cecret directory is not found
if [ ! -d "Cecret" ]; then
    echo "Error!  Can't find Cecret directory";
    exit 1;
fi

# Handles case where user gives data without "SampleSheet.csv" file in the input directory
if [ ! -f "$DATA/SampleSheet.csv" ]; then
	echo "Missing SampleSheet.csv in ${DATA} !";
	exit 1;
fi


CECRET_NEXTFLOW=$PWD/Cecret/Cecret_alltools.nf
CONFIG=$PWD/Cecret/configs/internal/singularity.config

CONFIG_FILE=$PWD/Cecret/configs/internal/settings.ini
R_IMG=$(grep -i R_IMG $CONFIG_FILE | cut -f 2 -d "=")
R_LIB=$(grep -i R_LIB $CONFIG_FILE | cut -f 2 -d "=")

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
OUTDIR=$PWD/Run_${current_time}_$(basename $DATA)

nextflow -v 2>&1 >/dev/null
if [ $? -gt 0 ]; then
	echo 'Error: make sure nextflow is installed: wget -qO- https://get.nextflow.io | bash'; 
	exit 1;
fi

nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR

# Stops the ^H character from being printed after running Nextflow
stty erase ^H

# Check for final summary file
if [ ! -f "$OUTDIR/summary.txt" ]; then
	echo "Run failed to complete...";
	exit 1;
fi

# for generating ORF(open reading frame) metrics and pdf reports
# R_IMG= ***replace with your own path here***

# R_IMG=${PWD}/SINGULARITY_CACHE/sc2clia-cecret-r_v2.1.0
if [ ! -f "$R_IMG" ]; then
	singularity pull $R_IMG $R_LIB
fi


runID=$(basename $DATA)
analysisDir=$OUTDIR
seqDir=$(realpath $DATA)


# bind path
MP=***set the binding path (top level recommended) for R container***
singularity run --bind /mnt,$MP --app orf_table $R_IMG $runID $analysisDir 2>&1 >/dev/null

singularity run --bind /mnt,$MP --app append_tables $R_IMG $analysisDir ${analysisDir}/summary.txt \
														   ${analysisDir}/pacbam_orf/orf_stats_summary.tsv 2>&1 >/dev/null

singularity run --bind /mnt,$MP --app report $R_IMG $runID $analysisDir $seqDir 2>&1 >/dev/null

echo "Done at" $(date "+%Y.%m.%d-%H.%M.%S")

python3 ${PWD}/Cecret/bin/elims_push.py -d $OUTDIR -s $OUTDIR/summary.txt