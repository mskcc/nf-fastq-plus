#!/bin/bash
# Runs Picard's CollectAlignmentSummaryMetrics
# Nextflow Inputs:
#   RUN_PARAMS_FILE, path - file w/ k=v pairs of parameters
#   BAM_CH, path - BAM file to analyz
#   STATSDONEDIR, env - Where to write stats
#
#   (config)
#   PICARD,     Picard Command
#   RUN_PARAMS_FILE, space delimited k=v pairs of run parameters
#   BAM_CH, Bam files to calculate metrics on
#   CMD_FILE          Absolute path to file that logs commands
# Nextflow Outputs:
#   None

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}  >> ${CMD_FILE}
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

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2 | sort | uniq
}

RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
REFERENCE=$(parse_param ${RUN_PARAMS_FILE} REFERENCE)   # Reference genome file to use
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
MACHINE=$(echo $RUNNAME | cut -d'_' -f1)

METRICS_DIR=${STATSDONEDIR}/${MACHINE}
mkdir -p ${METRICS_DIR}
AM_FILE="${METRICS_DIR}/${RUN_TAG}___AM.txt"

echo "Writing to ${AM_FILE}"

BAM=$(realpath *.bam)
CMD="${PICARD} CollectAlignmentSummaryMetrics MAX_INSERT_SIZE=1000 I=${BAM} O=${AM_FILE} R=${REFERENCE}"
run_cmd $CMD

# TODO - make metrics file available as output for nextlow
cp ${AM_FILE} .
