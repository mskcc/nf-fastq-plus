#!/bin/bash
# Submits an alignment to the reference
# Nextflow Inputs:
#   RUN_PARAMS_FILE
#   FASTQ_CH
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

# TODO 
# Make run directory in /igo/stats/, e.g. /igo/stats/DIANA_0239_AHL5G5DSXY - All alignment and stat files will go here

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard AddOrReplaceReadGroups ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}
  eval ${INPUT_CMD}
}

#########################################
# Runs BWA-MEM on input FASTQs
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   REFERENCE - FASTQ reference genome
#   DUAL - TODO
#   RUN_TAG - Tag for Run-Project-Sample
#   FASTQ* - absolute path to FASTQ
#########################################
bwa_mem () {
  LANE=$1
  REFERENCE=$2
  TYPE=$3
  DUAL=$4
  RUN_TAG=$5
  FASTQ1=$6
  FASTQ2=$7

  ENDEDNESS="Paired End"
  if [[ -z $FASTQ2 ]]; then
    # todo - test
    # Single end runs won't have a second FASTQ
    ENDEDNESS="Single End"
  fi
  
  # TODO - "______" is the delimiter that will be used to merge all SAMS from the same lane
  # TODO - This should be set in the config
  SAM_SMP="${RUN_TAG}______${LANE}"
  BWA_SAM="${SAM_SMP}___BWA.sam"
  RGP_SAM="${SAM_SMP}___RGP.sam"

  BWA_CMD="!{BWA} mem -M -t 36 ${REFERENCE} ${FASTQ1} ${FASTQ2} > ${BWA_SAM}"
  echo "BWA Run (${ENDEDNESS}): ${RUN_TAG} - Dual: $DUAL, Type: $TYPE, Out: ${BWA_SAM}"
  run_cmd $BWA_CMD
}

#########################################
# Reads input file and outputs param value
# Globals:
#   FILE - file of format "P1=V1 P2=V2 ..."
#   PARAM_NAME - name of parameter
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
parse_param() {
  FILE=$1
  PARAM_NAME=$2

  cat ${FILE}  | tr ' ' '\n' | grep ${PARAM_NAME} | cut -d '=' -f2
}

REFERENCE_PARAM=$(parse_param !{RUN_PARAMS_FILE} REFERENCE)
TYPE_PARAM=$(parse_param !{RUN_PARAMS_FILE} TYPE)
DUAL_PARAM=$(parse_param !{RUN_PARAMS_FILE} DUAL)
RUN_TAG_PARAM=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

# TODO - to run this script alone, we need a way to pass in this manually, e.g. FASTQ_LINKS=$(find . -type l -name "*.fastq.gz")
FASTQ_LINKS="!{FASTQ_CH}" 
FASTQS=$(echo ${FASTQ_LINKS} | xargs readlink -f)	# Retrieve source of sym-links

# Setup alignment for scatter - align each lane if lanes are present
LANES=$(echo $FASTQS | egrep -o '_L00._' | sed 's/_//g' | sort | uniq)
if [[ $(echo "$LANES" | wc -l) -eq 1 ]]; then
  echo "No Split Lanes: ${RUN_TAG}"
  FASTQ_ARGS=$(echo ${FASTQS} | awk '{printf $0 " " }')	# To single-lines
  bwa_mem "" $REFERENCE_PARAM $TYPE_PARAM $DUAL_PARAM $RUN_TAG_PARAM $FASTQ_ARGS
else
  echo "Spliting Lanes: ${RUN_TAG}"
  for LANE in $LANES; do
    LANE_FASTQS=$(echo $FASTQS | tr ' ' '\n' | grep $LANE)
    FASTQ_ARGS=$(echo ${LANE_FASTQS} | awk '{printf $0 " " }')
    bwa_mem $LANE $REFERENCE_PARAM $TYPE_PARAM $DUAL_PARAM $RUN_TAG_PARAM $FASTQ_ARGS
  done
fi


