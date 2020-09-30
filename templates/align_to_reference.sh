#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

echo "Will run BWA w/ $DUAL & $TYPE"
FASTQ_LINKS=$(find . -type l -printf "%p " -name "*.fastq.gz")
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)	# Retrieve source of sym-links
FASTQ_ARGS=$(echo ${FASTQS} | awk '{printf $0 " " }')	# To single-line
CMD="/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem -M -t 36 ${REFERENCE} ${FASTQ_ARGS}"
echo "Running $CMD"
# $CMD
