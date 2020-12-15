#!/bin/bash
# Runs Picard's CollectHsMetrics w/ valid BAITS/TARGETS
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#  
#   BAITS	Interval list for bait set
#   TARGETS     Interval list for target set  
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

if [[ ! -f ${BAITS} || ! -f ${TARGETS} ]]; then
  echo "Skipping CollectHsMetrics for ${RUN_TAG} (BAITS: ${BAITS}, TARGETS: ${TARGETS})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___AM.txt"

echo "[CollectHsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectHsMetrics BI=${BAITS} TI=${TARGETS} I=${BAM} O=${METRICS_FILE}"
run_cmd $CMD
