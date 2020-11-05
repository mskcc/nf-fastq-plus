#!/bin/bash
# Runs Picard's CollectWgsMetrics 
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#
#   GTAG        Indicator of reference genome (e.g. hg19, mm10, wgs)
#   REFERENCE	Reference genome to align to
#   RUNNAME	Name of the Run
#   RUN_TAG	Run Tag for the sample
# Nextflow Outputs:
#   None
# Run:
#   n/a

WGS_GENOMES="mm10\|wgs\|hg19"
if [ -z $(echo $GTAG | grep -i ${WGS_GENOMES}) ]; then 
  echo "Skipping CollectWgsMetrics for ${RUN_TAG}. GTAG (${GTAG}) not present in ${WGS_GENOMES}";
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___WGS.txt"
echo "[CollectWgsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"
touch $METRICS_FILE # TODO - delete

BAM=$(ls *.bam)
CMD="!{PICARD} CollectWgsMetrics I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"
echo $CMD
