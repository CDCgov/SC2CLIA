#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be run in your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder -p profile (default to v3)
# add -b b (any letter will do) argument if you want to run bbmap on filtered reads
usage() { echo "Usage: $0 <-d  specify data folder> <-p specify profile in config>" \
						 "<-b  type any letter to trigger using bbmap> " 1>&2; exit 1; }

while getopts "d:p:b:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
		p) PROFILE=${OPTARG} ;;
		b) BBMAP=${OPTARG} ;;
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

# check flag on bbmap
if [ -n "${BBMAP}" ]; then
	BBMAP=true
else
	BBMAP=false
fi


CECRET_NEXTFLOW=$PWD/Cecret/Cecret_alltools.nf
CONFIG=$PWD/Cecret/configs/internal/singularity.config

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
OUTDIR=$PWD/Run_${current_time}_$(basename $DATA)

nextflow -v 2>&1 >/dev/null
if [ $? -gt 0 ]; then
	echo 'Error: make sure nextflow is installed: wget -qO- https://get.nextflow.io | bash'; 
	exit 1;
fi

# check if there is profile argument
if [ -z "${PROFILE}" ]; then
	PROFILE=v3  # default to v3 profile
fi

nextflow run $CECRET_NEXTFLOW -c $CONFIG -profile $PROFILE --reads $DATA --outdir $OUTDIR --bbmap $BBMAP

# Stops the ^H character from being printed after running Nextflow
stty erase ^H