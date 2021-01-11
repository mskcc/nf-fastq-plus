#!/bin/bash
# Runs Picard's CollectOxoGMetrics if MSKQ=yes w/ valid BAITS/TARGETS
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#  
#   BAITS	Interval list for bait set
#   TARGETS     Interval list for target set  
#   RUNNAME	Name of the Run
#   REFERENC	Reference Genome for alignment
#   MSKQ	TODO
#   RUN_TAG	Run Tag for the sample
# Nextflow Outputs:
#   None
# Run:
#   n/a

# Skip if no valid BAITS/TARGETS or MSKQ=no
if [[ ! -f ${BAITS} || ! -f ${TARGETS} || -z $(echo $MSKQ | grep -i "yes") ]]; then
  echo "Skipping CollectOxoGMetrics for ${RUN_TAG} (BAITS: ${BAITS}, TARGETS: ${TARGETS} MSKQ: ${MSKQ})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___oxoG.txt"
echo "[CollectOxoGMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"
touch $METRICS_FILE # TODO - delete

BAM=$(ls *.bam)
CMD="!{PICARD} CollectOxoGMetrics CONTEXT_SIZE=0 I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"
echo $CMD
