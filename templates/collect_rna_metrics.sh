#!/bin/bash
# Runs Picard's CollectRnaSeqMetrics w/ valid RIBO_INTER/REF_FLAT
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#
#   RIBO_INTER  Interval list for ribosomal regions
#   REF_FLAT
#   RUNNAME	Name of the Run
#   RUN_TAG	Run Tag for the sample
# Nextflow Outputs:
#   None
# Run:
#   n/a

# Skip if no valid BAITS/TARGETS or MSKQ=no
if [[ ! -f ${RIBO_INTER} || ! -f ${REF_FLAT} ]]; then
  echo "Skipping CollectRnaSeqMetrics for ${RUN_TAG} (RIBO_INTER: ${RIBO_INTER}, REF_FLAT: ${REF_FLAT})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___RNA.txt"
echo "[CollectRnaSeqMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"
touch $METRICS_FILE # TODO - delete

BAM=$(ls *.bam)
CMD="!{PICARD} CollectRnaSeqMetrics RIBOSOMAL_INTERVALS=${RIBO_INTER} STRAND_SPECIFICITY=NONE REF_FLAT=${REF_FLAT} I=${BAM} O=${METRICS_FILE}"
echo $CMD
