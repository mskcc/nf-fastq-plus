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

if [[ ! -f ${BAITS} || ! -f ${TARGETS} ]]; then
  echo "Skipping CollectHsMetrics for ${RUN_TAG} (BAITS: ${BAITS}, TARGETS: ${TARGETS})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___AM.txt"
echo "[CollectHsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"
touch $METRICS_FILE # TODO - delete

BAM=$(ls *.bam)
CMD="!{PICARD} CollectHsMetrics BI=${BAITS} TI=${TARGETS} I=${BAM} O=${METRICS_FILE}"
echo $CMD
