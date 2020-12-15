#!/bin/bash
# Runs Picard's CollectAlignmentSummaryMetrics
# Nextflow Inputs:
#   PICARD,     Picard Command
# 
#   REFERNECE	Reference genome to run alignment on
#   RUN_TAG	Run Tag for the sample
# Nextflow Outputs:
#   None
# Run:
#   n/a

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}
  eval ${INPUT_CMD}
}

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
AM_FILE="${METRICS_DIR}/${RUN_TAG}___AM.txt"

echo "Writing to ${AM_FILE}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectAlignmentSummaryMetrics MAX_INSERT_SIZE=1000 I=${BAM} O=${AM_FILE} R=${REFERENCE}"
run_cmd $CMD
