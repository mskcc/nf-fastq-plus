#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

# TODO 
# Make run directory in /igo/stats/, e.g. /igo/stats/DIANA_0239_AHL5G5DSXY - All alignment and stat files will go here

FASTQ_LINKS=$(find . -type l -name "*.fastq.gz") 	# Sym-links
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)	# Retrieve source of sym-links
FASTQ_ARGS=$(echo ${FASTQS} | awk '{printf $0 " " }')	# To single-lines

SAMPLE_NAME=$(echo ${FASTQS} | xargs dirname | xargs basename | sed 's/Sample_//g' | sort | uniq)
if [[ $(echo ${SAMPLE_NAME}| wc -l) -ne 1 ]]; then
  # FASTQs should come from the same directory
  echo "Unable to determine sample name from FASTQS: ${SAMPLE_NAME}"
  exit 1
fi
OUT_SAM="${SAMPLE_NAME}___TMP.sam"
CMD="/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem -M -t 36 ${REFERENCE} ${FASTQ_ARGS} > ${OUT_SAM}"
echo "BWA - Sample: ${SAMPLE_NAME}, Dual: $DUAL, Type: $TYPE, Out: ${OUT_SAM}, CMD: $CMD"
# $CMD
