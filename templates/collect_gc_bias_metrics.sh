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
  INPUT_CMD=$1
  echo ${INPUT_CMD}
  eval ${INPUT_CMD}
}

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.txt"
METRICS_PDF="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.pdf"
SUMMARY_FILE="${METRICS_DIR}/${RUN_TAG}___gc_summary_metrics.txt"
echo "[CollectWgsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE} & ${METRICS_PDF}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectGcBiasMetrics ASSUME_SORTED=true I=${BAM} O=${METRICS_FILE} CHART=${METRICS_PDF} S=${SUMMARY_FILE} R=${REFERENCE}"
run_cmd $CMD
