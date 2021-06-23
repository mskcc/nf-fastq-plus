#!/bin/bash
# Runs Picard's CollectGcBiasMetrics
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#
#   RUN_PARAMS_FILE, space delimited k=v pairs of run parameters
#   BAM_CH, Bam files to calculate metrics on
# Nextflow Outputs:
#   None

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD} >> ${CMD_FILE}
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

RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
REFERENCE=$(parse_param ${RUN_PARAMS_FILE} REFERENCE)   # Reference genome file to use
RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
MACHINE=$(echo $RUNNAME | cut -d'_' -f1)

METRICS_DIR=${STATSDONEDIR}/${MACHINE}  # Location of metrics & BAMs
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.txt"
METRICS_PDF="${METRICS_DIR}/${RUN_TAG}___gc_bias_metrics.pdf"
SUMMARY_FILE="${METRICS_DIR}/${RUN_TAG}___gc_summary_metrics.txt"
echo "[CollectGcBiasMetrics:${RUN_TAG}] Writing to ${METRICS_FILE} & ${METRICS_PDF}"

BAM=$(realpath *.bam)
set +e
CMD="${PICARD} CollectGcBiasMetrics ASSUME_SORTED=true I=${BAM} O=${METRICS_FILE} CHART=${METRICS_PDF} S=${SUMMARY_FILE} R=${REFERENCE}"
set -e
run_cmd $CMD
GC_BIAS_EXIT_CODE=$?
echo "CollectGcBiasMetrics Error Code: ${GC_BIAS_EXIT_CODE}"
if [[ 137 -eq ${GC_BIAS_EXIT_CODE} || 0 -eq ${GC_BIAS_EXIT_CODE} ]]; then
  echo "CollectGcBiasMetrics succeeded, or ran out of memory. Continuing..."
else
  echo "CollectGcBiasMetrics failed for an unexpected reason. Exiting."
  exit 1
fi

# TODO - make metrics file available as output for nextlow
cp ${METRICS_FILE} .
