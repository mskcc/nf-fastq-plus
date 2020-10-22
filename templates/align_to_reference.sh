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

#########################################
# Runs BWA-MEM on input FASTQs
# Globals:
#   REFERENCE - FASTQ reference genome
#   OUT_BWA - Suffix (in nextflow.config)
#   RUN_TAG - Tag for Run-Project-Sample
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
bwa_mem () {
  LANE=$1
  FASTQ1=$2
  FASTQ2=$3

  ENDEDNESS="Paired End"
  if [[ -z $FASTQ2 ]]; then
    # todo - test
    # Single end runs won't have a second FASTQ
    ENDEDNESS="Single End"
  fi

  OUT_SAM="${RUN_TAG}___${LANE}___${OUT_BWA}.sam"
  CMD="/opt/common/CentOS_7/bwa/bwa-0.7.17/bwa mem -M -t 36 ${REFERENCE} ${FASTQ1} ${FASTQ2} > ${OUT_SAM}"
  echo "BWA Run (${ENDEDNESS}): ${RUN_TAG} - Dual: $DUAL, Type: $TYPE, Out: ${OUT_SAM}"
  echo $CMD

  # TODO - Replace with actually running the command
  touch $OUT_SAM
  # $CMD
}

# TODO - to run this script alone, we need a way to pass in this manually, e.g. FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")
FASTQ_LINKS="!{FASTQ_CH}" 
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)	# Retrieve source of sym-links

# Setup alignment for scatter - align each lane if lanes are present
LANES=$(echo $FASTQS | egrep -o '_L00._' | sed 's/_//g' | sort | uniq)
if [[ $(echo "$LANES" | wc -l) -eq 1 ]]; then
  echo "No Split Lanes: ${RUN_TAG}"
  FASTQ_ARGS=$(echo ${FASTQS} | awk '{printf $0 " " }')	# To single-lines
  bwa_mem "" $FASTQ_ARGS
else
  echo "Spliting Lanes: ${RUN_TAG}"
  for LANE in $LANES; do
    LANE_FASTQS=$(echo $FASTQS | tr ' ' '\n' | grep $LANE)
    FASTQ_ARGS=$(echo ${LANE_FASTQS} | awk '{printf $0 " " }')
    bwa_mem $LANE $FASTQ_ARGS
  done
fi

