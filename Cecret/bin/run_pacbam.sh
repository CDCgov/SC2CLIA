#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8


usage() { echo "Usage: $0 <-d bed file> <-b bam folder> <-f reference fasta> <-v vcf folder> \
                          <-m mode (0..4)> <-o outdir> <-s suffix>"1>&2; exit 1; }

MODE=1
OUTDIR=.
THREADS=20

while getopts "d:b:f:v:m:o:p:s:" o; do
	case $o in
		d) BED=${OPTARG} ;;
		b) BAM=${OPTARG} ;;
		f) FASTA=${OPTARG} ;;
		v) VCF=${OPTARG} ;;
		m) MODE=${OPTARG} ;;
		o) OUTDIR=${OPTARG} ;;
		s) SUFFIX=${OPTARG} ;;
		# *) usage ;;
	esac
done

# if [ -z "${DATA}" ]; then
#     usage
# fi

# if [ ! -d "Cecret" ]; then
#     echo "Error!  Can't find Cecret directory";
#     exit 1;
# fi

for file in $BAM/*bam; do 
	sample=$(basename ${file} | cut -d'.' -f 1);
	if [ ! -d "$OUTDIR/$sample/$SUFFIX" ]; then
		mkdir -p $OUTDIR/$sample/$SUFFIX;
	fi
	#$PAC_PATH bam=${file} bed=$BED vcf=$VCF/$sample.vcf fasta=$FASTA mode=$MODE out=$OUTDIR/$sample/$SUFFIX threads=$THREADS;
	pacbam bam=${file} bed=$BED vcf=$VCF/$sample.vcf fasta=$FASTA mode=$MODE out=$OUTDIR/$sample/$SUFFIX threads=$THREADS;
done




