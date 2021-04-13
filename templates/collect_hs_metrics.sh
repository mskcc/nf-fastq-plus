#!/bin/bash
# Runs Picard's CollectHsMetrics w/ valid BAITS/TARGETS
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
  echo ${INPUT_CMD} >> !{CMD_FILE}
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

RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)
BAITS=$(parse_param !{RUN_PARAMS_FILE} BAITS)       # Interval list of bait sites
TARGETS=$(parse_param !{RUN_PARAMS_FILE} TARGETS)   # Interval list of target sites
RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
STAT_FILE_NAME="${RUN_TAG}___HS.txt"

if [[ ! -f ${BAITS} || ! -f ${TARGETS} ]]; then
  echo "Skipping CollectHsMetrics for ${RUN_TAG} (BAITS: ${BAITS}, TARGETS: ${TARGETS})"
else
    mkdir -p ${METRICS_DIR}
  METRICS_FILE="${METRICS_DIR}/${STAT_FILE_NAME}"

  echo "[CollectHsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

  BAM=$(realpath *.bam)
  CMD="!{PICARD} CollectHsMetrics BI=${BAITS} TI=${TARGETS} I=${BAM} O=${METRICS_FILE}"
  run_cmd $CMD

  # TODO - make metrics file available as output for nextlow
  cp ${METRICS_FILE} .
fi
