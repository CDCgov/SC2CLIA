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
OUTDIR=$PWD/Run_${current_time}_$(basename $DATA)

$CECRET_BASE/nextflow run $CECRET_NEXTFLOW -c $CONFIG --reads $DATA --outdir $OUTDIR \
							--kraken2 true --kraken2_db=$CECRET_BASE/kraken2_db \
							--pacbam $PB --vadr $VADR

# Stops the ^H character from being printed after running Nextflow
stty erase ^H


# Begin Report block
echo "running R scripts to generate reports ..."

R_IMG=$CECRET_BASE/SINGULARITY_CACHE/singularity-r.sif
R_folder=${PWD}/Cecret/bin/report

# -r, -a, and -s
runID=$(basename $DATA)
analysisDir=$OUTDIR
seqDir=$(realpath $DATA)

##singularity exec --no-home -B  ***replace with your own path here***

singularity exec \
				--no-home \
				-B $seqDir:/data:ro,${R_folder}:/usr/local/bin:rw,${analysisDir}:/OUTDIR:rw \
				-H /usr/local/bin \
				${R_IMG} \
					config.R -r $runID -a /OUTDIR -s /data > /dev/null

echo "Done!"
