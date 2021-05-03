#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be ran in $CECRET_BASE or your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder [-r true/false]

usage() { echo "Usage: $0 <-d  specify data folder> <-r  true:false flag to generate report files>" 1>&2; exit 1; }

RSCRIPT=true
while getopts "d:r:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
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

nextflow -v || (echo 'make sure nextflow is installed: wget -qO- https://get.nextflow.io | bash'; exit 1)

nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR \
							--kraken2 true --kraken2_db=$CECRET_BASE/kraken2_db

# Stops the ^H character from being printed after running Nextflow
stty erase ^H

# Check for final summary file
if [ ! -f "$OUTDIR/summary.txt" ]; then
	echo "Run failed to complete...";
	exit 1;
fi


# If Rscript option turned on, begin Report block
# if [ ! ${RSCRIPT} ]; then
if [ ! ${RSCRIPT} = true ]; then
	echo "Completed Cecret pipeline";
	exit 0;
else
	echo "Running R scripts to generate reports ...";
fi

R_IMG=$CECRET_BASE/SINGULARITY_CACHE/singularity-r.sif
# R_IMG=$PWD/SINGULARITY_CACHE/singularity-r.sif
R_folder=${PWD}/Cecret/bin/report
ORF_folder=${PWD}/Cecret/bin

config_folder=${PWD}/Cecret/configs

# -b, -t
bed1="MN908947.3-ORFs.bed"
bed2="MN908947.3-ORF7b.bed"

# -r, -a, and -s
runID=$(basename $DATA)
analysisDir=$OUTDIR
seqDir=$(realpath $DATA)


singularity exec \
				--no-home \
				-B ${ORF_folder}:/usr/local/bin:rw,${analysisDir}:/OUTDIR:rw,${config_folder}:/configs \
				-H /usr/local/bin \
				${R_IMG} orf_table.R -r ${runID} -a /OUTDIR -b /configs/${bed1} -t /configs/${bed2} 2>&1 >/dev/null


singularity exec \
				--no-home \
				-B $seqDir:/data:ro,${R_folder}:/usr/local/bin:rw,${analysisDir}:/OUTDIR:rw \
				-H /usr/local/bin \
				${R_IMG} config.R -r ${runID} -a /OUTDIR -s /data 2>&1 >/dev/null

singularity exec \
				--no-home \
				-B ${ORF_folder}:/usr/local/bin:rw,${analysisDir}:/OUTDIR:rw,${config_folder}:/configs \
				-H /usr/local/bin \
				${R_IMG} append_tables.R -a /OUTDIR  -f /OUTDIR/summary.txt -s /OUTDIR/pacbam_orf/orf_stats_summary.tsv 2>&1 >/dev/null

echo "Done!"
