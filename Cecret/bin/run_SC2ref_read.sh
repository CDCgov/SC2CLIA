#!/bin/bash

usage() { echo "Usage: $0 <-r Run folder> "1>&2; exit 1; }

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


for bam in $RUN/aligned/*.bam;do

    sample=$(basename ${bam} | cut -d'.' -f 1);
    num=`samtools stats ${bam} | grep 'reads mapped and paired' | cut -f 3`;
    denom=`awk 'NR%4 == 1 {print $0}' <(cat $RUN/seqyclean/$sample*PE1.fastq \
    	                                $RUN/seqyclean/$sample*PE2.fastq) | wc -l`;
    div=`echo $num / $denom | bc -l`;
    echo $sample $div >> $RUN/sc2.txt;
    echo  $sample $div
    
done
