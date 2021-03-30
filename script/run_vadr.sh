#!/bin/bash

#$ -N run_cecret
#$ -cwd
#$ -pe smp 8


usage() { echo "Usage: $0 <-m mdir> <-f consensus fasta dir> <-o output folder>"1>&2; exit 1; }

while getopts "m:f:o:" o; do
	case $o in
		m) MDIR=${OPTARG} ;;
		f) FASTA=${OPTARG} ;;
		o) OUTDIR=${OPTARG} ;;
		# *) usage ;;
	esac
done

for file in $FASTA/*.fa; do 
	sample=$(basename ${file} | cut -d'.' -f 1);
	echo $sample
	if [ ! -d "$OUTDIR/$sample" ]; then
		mkdir -p $OUTDIR/$sample;
	fi
	# v-annotate.pl -h &> $OUTDIR/$sample/help.txt
	v-annotate.pl --noseqnamemax --mxsize 64000 -s -r --nomisc --mkey NC_045512 --lowsim5term 2 --lowsim3term 2 --fstlowthr 0.0 --alt_fail lowscore,fsthicnf,fstlocnf,insertnn,deletinn --mdir $MDIR $file $OUTDIR/$sample
done
