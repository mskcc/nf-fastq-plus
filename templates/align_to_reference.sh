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

# TODO - to run this script alone, we need a way to pass in this manually, e.g. FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")
FASTQ_LINKS="!{FASTQ_CH}" 
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)	# Retrieve source of sym-links
FASTQ_ARGS=$(echo ${FASTQS} | awk '{printf $0 " " }')	# To single-lines
OUT_SAM="${RUN_TAG}___${OUT_BWA}.sam"
CMD="/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem -M -t 36 ${REFERENCE} ${FASTQ_ARGS} > ${OUT_SAM}"
echo "BWA Run: ${RUN_TAG} - Dual: $DUAL, Type: $TYPE, Out: ${OUT_SAM}, CMD: $CMD"

# TODO - Replace with actually running the command
touch $OUT_SAM
echo $CMD
# $CMD
