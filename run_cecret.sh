#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be ran in $CECRET_BASE or your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder -p true -r true
# -p is optional to turn on pacbam process

usage() { echo "Usage: $0 <-d  specify data folder> <-p  true:false flag to run pacbam> <-r  true:false flag to generate report files>" 1>&2; exit 1; }

# NCPARSE is turning off the nextcladeParse process for the failures on the "NC" reads
NCPARSE=false

PB=true
RSCRIPT=true
while getopts "d:p:r:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
    	p) PB=${OPTARG} ;;
		r) RSCRIPT=${OPTARG} ;;
		*) usage ;;
	esac
done

# Display help if not arguments
if [ -z "${DATA}" ]; then
    usage
fi

# Exit if Cecret directory is not found
if [ ! -d "Cecret" ]; then
    echo "Error!  Can't find Cecret directory";
    exit 1;
fi

# Handles case where user gives data without "SampleSheet.csv" file in the input directory
if [ ${RSCRIPT} ] && [ ! -f "$DATA/SampleSheet.csv" ]; then
	echo "Missing SampleSheet.csv in ${DATA}!";
	echo "Report files will not be generated. Continue anyway?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes ) RSCRIPT=false; break;;
	        No ) exit 1;;
	    esac
	done
fi


CECRET_BASE= ***replace with your own path here***
#CECRET_NEXTFLOW=$CECRET_BASE/Cecret/Cecret_alltools.nf
CECRET_NEXTFLOW=$PWD/Cecret/Cecret_alltools.nf
#CONFIG=$CECRET_BASE/Cecret/configs/singularity.config
CONFIG=$PWD/Cecret/configs/singularity.config

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
# OUTDIR=$CECRET_BASE/Run_$current_time_$(basename $DATA)
OUTDIR=$PWD/Run_${current_time}_$(basename $DATA)

$CECRET_BASE/nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR \
							--kraken2 true --kraken2_db=$CECRET_BASE/kraken2_db \
							--pacbam $PB --nextcladeParse $NCPARSE

# Stops the ^H character from being printed after running Nextflow
stty erase ^H

if [ ! -f "$OUTDIR/summary.txt" ]; then
	echo "Run failed to complete...";
	exit 1;
fi


if [ ! ${RSCRIPT} ]; then
	echo "Done.";
	exit 0;
fi
# If Rscript option turned on, begin Report block
echo "Running R scripts to generate reports ..."

R_IMG=$CECRET_BASE/SINGULARITY_CACHE/singularity-r.sif
# R_IMG=$PWD/SINGULARITY_CACHE/singularity-r.sif
R_folder=${PWD}/Cecret/bin/report

# -r, -a, and -s
runID=$(basename $DATA)
analysisDir=$OUTDIR
seqDir=$(realpath $DATA)

singularity exec \
				--no-home \
				-B $seqDir:/data:ro,${R_folder}:/usr/local/bin:rw,${analysisDir}:/OUTDIR:rw \
				-H /usr/local/bin \
				${R_IMG} config.R -r ${runID} -a /OUTDIR -s /data > /dev/null

echo "Done!"
