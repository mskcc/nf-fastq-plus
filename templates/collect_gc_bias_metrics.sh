#!/bin/bash
# Runs Picard's CollectGcBiasMetrics
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#
#   REFERENCE	Reference genome to align to
#   RUNNAME	Name of the Run
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

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)
REFERENCE=$(parse_param !{RUN_PARAMS_FILE} REFERENCE)
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.txt"
METRICS_PDF="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.pdf"
SUMMARY_FILE="${METRICS_DIR}/${RUN_TAG}___gc_summary_metrics.txt"
echo "[CollectGcBiasMetrics:${RUN_TAG}] Writing to ${METRICS_FILE} & ${METRICS_PDF}"

BAM=$(realpath *.bam)
CMD="!{PICARD} CollectGcBiasMetrics ASSUME_SORTED=true I=${BAM} O=${METRICS_FILE} CHART=${METRICS_PDF} S=${SUMMARY_FILE} R=${REFERENCE}"
run_cmd $CMD
