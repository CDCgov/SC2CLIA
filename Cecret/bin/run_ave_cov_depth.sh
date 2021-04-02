#!/bin/bash

usage() { echo "Usage: $0 <-r Run folder in absolute path> " 1>&2; exit 1; }

while getopts "r:" o;do
	case $o in
		r) RUN=${OPTARG} ;;
		*) usage ;;
	esac
done

if [ -z "${RUN}" ]; then
    usage
fi


if [ ! -d ${RUN} ]; then
    echo "Error!  Can't find $RUN directory";
    exit 1;
fi


module load bwa
mkdir -p $RUN/consensus/consensus-aligned

for fa in $RUN/consensus/*.fa;do

    sample=$(basename ${fa} | cut -d'.' -f 1);
    bwa index ${fa};
    bwa mem -t 10  ${fa} $RUN/seqyclean/$sample*PE1.fastq $RUN/seqyclean/$sample*PE2.fastq > \
                   $RUN/consensus/consensus-aligned/$sample.sam;
    samtools sort $RUN/consensus/consensus-aligned/$sample.sam | samtools view -F 4 -o $RUN/consensus/consensus-aligned/$sample.sorted.bam;
    result=`samtools mpileup -a -d 8000 -f ${fa} $RUN/consensus/consensus-aligned/$sample.sorted.bam | \
    awk '$3 != "N" { SUM += $4; COUNT += 1 } END { if (COUNT > 0) {print SUM/COUNT} else {print -1} }'`;
    echo $sample $result >> temp.txt;

done

# get rid of those 'index' files
rm $RUN/consensus/*.fa.*

# attach the result to the summary file
python3 ave_cov_depth.py -i temp.txt -o $RUN/summary.txt

rm temp.txt