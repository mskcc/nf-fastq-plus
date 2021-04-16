#!/bin/bash
# Runs Picard's CollectRnaSeqMetrics w/ valid RIBO_INTER/REF_FLAT
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

RIBO_INTER=$(parse_param ${RUN_PARAMS_FILE} RIBOSOMAL_INTERVALS) # Interval list of ribosomal sites
REF_FLAT=$(parse_param ${RUN_PARAMS_FILE} REF_FLAT)        # Reference genome file to use
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
MACHINE=$(echo $RUNNAME | cut -d'_' -f1)

METRICS_DIR=${STATSDONEDIR}/${MACHINE}  # Location of metrics & BAMs
STATS_FILENAME="${RUN_TAG}___RNA.txt"

# Skip if no valid BAITS/TARGETS or MSKQ=no
if [[ ! -f ${RIBO_INTER} || ! -f ${REF_FLAT} ]]; then
  MSG="Skipping CollectRnaSeqMetrics for ${RUN_TAG} (RIBO_INTER: ${RIBO_INTER}, REF_FLAT: ${REF_FLAT})"
  echo $MSG
  echo $MSG >> ${STATS_FILENAME}
else
  METRICS_FILE="${METRICS_DIR}/${STATS_FILENAME}"
  mkdir -p ${METRICS_DIR}
  echo "[CollectRnaSeqMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

  BAM=$(realpath *.bam)
  CMD="${PICARD} CollectRnaSeqMetrics RIBOSOMAL_INTERVALS=${RIBO_INTER} STRAND_SPECIFICITY=NONE REF_FLAT=${REF_FLAT} I=${BAM} O=${METRICS_FILE}"
  run_cmd $CMD

  # TODO - make metrics file available as output for nextlow
  cp ${METRICS_FILE} .
fi
