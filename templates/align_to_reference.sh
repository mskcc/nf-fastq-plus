#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   BWA
#   PICARD
#
#   RUN_TAG
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

  SAM_SMP="${RUN_TAG}___${LANE}___${OUT_BWA}"
  BWA_SAM="${SAM_SMP}___TMP.sam"
  RG_SAM="${SAM_SMP}.sam"
  # TODO - define BWA_MEM
  CMD="!{BWA} mem -M -t 36 ${REFERENCE} ${FASTQ1} ${FASTQ2} > ${BWA_SAM}"
  echo "BWA Run (${ENDEDNESS}): ${RUN_TAG} - Dual: $DUAL, Type: $TYPE, Out: ${BWA_SAM}"
  
  # TODO - Replace with actually running the command
  echo $CMD
  touch $BWA_SAM

  # AddOrReplaceReadGroups
  CMD="!{PICARD} AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true I=${BWA_SAM} O=${RG_SAM} ID=${RUN_TAG} LB=${RUN_TAG} PU=${PROJECT_TAG} SM=${SAMPLE_TAG}  PL=illumina CN=IGO@MSKCC"

  # TODO - Replace w/ actual command
  echo $CMD
  touch ${RG_SAM}
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


