#!/bin/bash

usage() { echo "Usage: $0 <-p  specify bbmap ref path>" \
						  "<-r  specify bbmap ref name>" \
						  "<-o  specify reads directory> " 1>&2; exit 1; }

while getopts "p:r:o:" o; do
	case $o in
		p) BB_PATH=${OPTARG} ;;
		r) BB_REF=${OPTARG} ;;
		o) OUTDIR=${OPTARG} ;;
		*) usage ;;
	esac
done

# all arguments are required
if [ -z "${BB_PATH}" ] || [ -z "${BB_REF}" ] || [ -z "${OUTDIR}" ]; then
    usage
fi


# compile inlist, in2list, outmlist for bbwrap.sh
mkdir -p ${OUTDIR}/filter/bbmap
for file in ${OUTDIR}/filter/*.gz; do
	if echo $file | grep -q '_R1'; then
		echo $file >> ${OUTDIR}/filter/bbmap/R1.txt
		temp=$(echo $(basename $file) | grep -o '.*_R1')
		echo ${OUTDIR}/filter/bbmap/${temp}.fasta >> ${OUTDIR}/filter/bbmap/outm_paired.txt
	elif echo $file | grep -q '_R2'; then
		echo $file >> ${OUTDIR}/filter/bbmap/R2.txt
	elif echo $file | grep -q 'unpaired'; then
		echo $file >> ${OUTDIR}/filter/bbmap/unpaired.txt
		temp=$(echo $(basename $file) | grep -o '.*unpaired')
		echo ${OUTDIR}/filter/bbmap/${temp}.fasta >> ${OUTDIR}/filter/bbmap/outm_unpaired.txt
	fi
done

bbwrap.sh \
			ref=$BB_REF \
			path=$BB_PATH \
			inlist=${OUTDIR}/filter/bbmap/R1.txt \
			in2list=${OUTDIR}/filter/bbmap/R2.txt \
			outmlist=${OUTDIR}/filter/bbmap/outm_paired.txt \
			minratio=0.9 >/dev/null 2>&1

bbwrap.sh \
			ref=$BB_REF \
			path=$BB_PATH \
			inlist=${OUTDIR}/filter/bbmap/unpaired.txt \
			outmlist=${OUTDIR}/filter/bbmap/outm_unpaired.txt \
			minratio=0.9 >/dev/null 2>&1

# run bbduk.sh to weed out low-complexity sequences
for file in ${OUTDIR}/filter/bbmap/*.fasta; do
	if [ -s $file ]; then
		mv $file ${file}.fasta
		bbduk.sh \
					in=${file}.fasta \
					out=$file \
					entropy=0.7 >/dev/null 2>&1
		rm ${file}.fasta
	fi
done

for file in ${OUTDIR}/filter/bbmap/*.fasta; do
	hits=$(grep '>' $file | wc -l)
	temp=$(echo $file | grep -o '.*[^.fasta]')
	num_total=$(gunzip -c ${OUTDIR}/filter/$(basename $temp).fastq.gz | echo $((`wc -l`/4)))
    if (( $num_total == 0 )); then
      percent_hit=NA
    else
      percent_hit=$(echo "$hits $num_total" | awk '{printf "%.3f", $1*100/$2}')
    fi
    echo "$(basename $temp), we found $hits hits out of $num_total sequences, with hit_ratio = $percent_hit%" >> ${OUTDIR}/filter/bbmap/bbmap_result.txt
done

# remove everything except the bbmap result file
mv ${OUTDIR}/filter/bbmap/bbmap_result.txt ${OUTDIR}/filter/bbmap_result.txt 
rm ${OUTDIR}/filter/bbmap/*
mv ${OUTDIR}/filter/bbmap_result.txt ${OUTDIR}/filter/bbmap/bbmap_result.txt