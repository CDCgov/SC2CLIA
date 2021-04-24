#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be ran in $CECRET_BASE or your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder -p true  
# -p is optioal to turn on pacbam process

usage() { echo "Usage: $0 <-d  specify data folder> <-p  true:false flag to run pacbam> \
               <-v  true:false flag to run vadr> <-r  true:false flag to run R script to generate report>" \
               1>&2; exit 1; }

PB=true
VADR=true
R_script=true
while getopts "d:p:v:r:" o; do
	case $o in
		d) DATA=${OPTARG} ;;
    p) PB=${OPTARG} ;;
		v) VADR=${OPTARG} ;;
    r) R_script=${OPTARG} ;;
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

if [[ R_script =~ true ]]; then

	R_IMG=$CECRET_BASE/SINGULARITY_CACHE/singularity-r.sif

	runR_script=/mnt/cecret_test_prod/Cecret/bin/report/runR.sh
	# we need to cd to the report dir first
	report_dir=/mnt/cecret_test_prod/Cecret/bin/report
	# this is Jo's main R script
	mainR_script=/mnt/cecret_test_prod/Cecret/bin/report/config.R

	# these 3 are the arguments fed into mainR script
	run_result_dir=/mnt/cecret_test_prod/Run\_$current_time\_$(basename $DATA)
	run_name=$(basename $DATA)
	run_dir=`echo $DATA | sed 's/\***set the binding path (top level recommended) for R container***\/groups\/OID\/NCEZID\/DFWED\/EDLB\/projects\/SC2-Seq-CLIA/\/mnt/'`

	# if to run it in your local folder, you might want to change the mnt path and/or other file/dir path accordingly
	singularity exec --no-home -B  ***replace with your own path here***
	                $runR_script $report_dir $mainR_script $run_result_dir $run_name $run_dir
	                
fi
