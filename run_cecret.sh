#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8

# NOTE:
# this script should only be run in your local git repo folder
# this script can be called upon as: ./run_cecret.sh -d sample_folder -p profile (default to v3)

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


CECRET_NEXTFLOW=$PWD/Cecret/Cecret_alltools.nf
CONFIG=$PWD/Cecret/configs/internal/singularity.config

CONFIG_FILE=$PWD/Cecret/configs/internal/settings.ini
R_IMG=$(grep -i R_IMG $CONFIG_FILE | cut -f 2 -d "=")
R_LIB=$(grep -i R_LIB $CONFIG_FILE | cut -f 2 -d "=")
BB_IMG=$(grep -i BB_IMG $CONFIG_FILE | cut -f 2 -d "=")
BB_LIB=$(grep -i BB_LIB $CONFIG_FILE | cut -f 2 -d "=")
BB_PATH=$(grep -i BB_PATH $CONFIG_FILE | cut -f 2 -d "=")
BB_REF=$(grep -i BB_REF $CONFIG_FILE | cut -f 2 -d "=")

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

nextflow run $CECRET_NEXTFLOW -c $CONFIG -profile $PROFILE --reads $DATA --outdir $OUTDIR

# Stops the ^H character from being printed after running Nextflow
stty erase ^H

# Check for final summary file
if [ ! -f "$OUTDIR/summary.txt" ]; then
	echo "Run failed to complete...";
	exit 1;
fi

# for generating ORF(open reading frame) metrics and pdf reports
# R_IMG=${PWD}/SINGULARITY_CACHE/sc2clia-cecret-r_v2.1.0
if [ ! -f "$R_IMG" ]; then
	singularity pull $R_IMG $R_LIB
fi


runID=$(basename $DATA)
analysisDir=$OUTDIR
seqDir=$(realpath $DATA)


# bind path
MP=***set the binding path (top level recommended) for R container***
singularity run --bind /mnt,$MP --app orf_table $R_IMG $runID $analysisDir >/dev/null 2>&1

singularity run --bind /mnt,$MP --app append_tables $R_IMG $analysisDir ${analysisDir}/summary.txt \
														   ${analysisDir}/pacbam_orf/orf_stats_summary.tsv >/dev/null 2>&1

singularity run --bind /mnt,$MP --app report $R_IMG $runID $analysisDir $seqDir >/dev/null 2>&1

echo "Done at" $(date "+%Y.%m.%d-%H.%M.%S")

python3 ${PWD}/Cecret/bin/elims_push.py -d $OUTDIR -s $OUTDIR/summary.txt

# run bbmap on filtered reads
if [ -n "${BBMAP}" ]; then
	echo "calling bbmap on the filtered reads..."
	${PWD}/Cecret/bin/bbmap.sh -b $MP -i $BB_IMG -l $BB_LIB -p $BB_PATH -r $BB_REF -o $OUTDIR
	echo "Done at" $(date "+%Y.%m.%d-%H.%M.%S")
fi

##### bbmap ######
# if [ ! -f "$BB_IMG" ]; then
# 	singularity pull $BB_IMG $BB_LIB
# fi

# # compile inlist, in2list, outmlist for bbwrap.sh
# mkdir -p ${OUTDIR}/filter/bbmap
# for file in ${OUTDIR}/filter/*.gz; do
# 	if echo $file | grep -q '_R1'; then
# 		echo $file >> ${OUTDIR}/filter/bbmap/R1.txt
# 		temp=$(echo $(basename $file) | grep -o '.*_R1')
# 		echo ${OUTDIR}/filter/bbmap/${temp}.fasta >> ${OUTDIR}/filter/bbmap/outm_paired.txt
# 	elif echo $file | grep -q '_R2'; then
# 		echo $file >> ${OUTDIR}/filter/bbmap/R2.txt
# 	elif echo $file | grep -q 'unpaired'; then
# 		echo $file >> ${OUTDIR}/filter/bbmap/unpaired.txt
# 		temp=$(echo $(basename $file) | grep -o '.*unpaired')
# 		echo ${OUTDIR}/filter/bbmap/${temp}.fasta >> ${OUTDIR}/filter/bbmap/outm_unpaired.txt
# 	fi
# done


# singularity run --bind /mnt,$MP $BB_IMG bbwrap.sh \
# 			ref=$BB_REF \
# 			path=$BB_PATH \
# 			inlist=${OUTDIR}/filter/bbmap/R1.txt \
# 			in2list=${OUTDIR}/filter/bbmap/R2.txt \
# 			outmlist=${OUTDIR}/filter/bbmap/outm_paired.txt \
# 			minratio=0.9 >/dev/null 2>&1

# singularity run --bind /mnt,$MP $BB_IMG bbwrap.sh \
# 			ref=$BB_REF \
# 			path=$BB_PATH \
# 			inlist=${OUTDIR}/filter/bbmap/unpaired.txt \
# 			outmlist=${OUTDIR}/filter/bbmap/outm_unpaired.txt \
# 			minratio=0.9 >/dev/null 2>&1

# # run bbduk.sh to weed out low-complexity sequences
# for file in ${OUTDIR}/filter/bbmap/*.fasta; do
# 	if [ -s $file ]; then
# 		mv $file ${file}.fasta
# 		singularity run --bind /mnt,$MP $BB_IMG bbduk.sh \
# 					in=${file}.fasta \
# 					out=$file \
# 					entropy=0.7 >/dev/null 2>&1
# 		rm ${file}.fasta
# 	fi
# done

# for file in ${OUTDIR}/filter/bbmap/*.fasta; do
# 	hits=$(grep '>' $file | wc -l)
# 	temp=$(echo $file | grep -o '.*[^.fasta]')
# 	num_total=$(gunzip -c ${OUTDIR}/filter/$(basename $temp).fastq.gz | echo $((`wc -l`/4)))
#     if (( $num_total == 0 )); then
#       percent_hit=NA
#     else
#       percent_hit=$(echo "$hits $num_total" | awk '{printf "%.3f", $1*100/$2}')
#     fi
#     echo "$(basename $temp), we found $hits hits out of $num_total sequences, with hit_ratio = $percent_hit%" >> ${OUTDIR}/filter/bbmap/bbmap_result.txt
# done

