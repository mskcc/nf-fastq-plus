#!/bin/bash
# Runs Picard's CollectWgsMetrics 
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

GTAG=$(parse_param ${RUN_PARAMS_FILE} GTAG)              # Must include a WGS genome to run CollectWgsMetrics
TYPE=$(parse_param ${RUN_PARAMS_FILE} TYPE)              # type is used to flag analysis like CollectWgsMetrics
REFERENCE=$(parse_param ${RUN_PARAMS_FILE} REFERENCE)    # Reference genome file to use
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
MACHINE=$(echo $RUNNAME | cut -d'_' -f1)

METRICS_DIR=${STATSDONEDIR}/${MACHINE}  # Location of metrics & BAMs
STATS_FILENAME="${RUN_TAG}___WGS.txt"
METRICS_FILE="${METRICS_DIR}/${STATS_FILENAME}"

WGS_GENOMES="mm10\|wgs\|hg19\|grch37"
if [ -z $(echo $GTAG | grep -i ${WGS_GENOMES}) ]; then
  MSG="Skipping CollectWgsMetrics for ${RUN_TAG}. GTAG (${GTAG}) not present in ${WGS_GENOMES} (TYPE: ${TYPE})";
  echo $MSG > ${STATS_FILENAME}
elif [ "${TYPE^^}" != "WGS" ]; then
  echo "Skipping CollectWgsMetrics for ${RUN_TAG}. TYPE: ${TYPE} != WGS (GTAG: ${GTAG})"
  echo $MSG > ${STATS_FILENAME}
else
  mkdir -p ${METRICS_DIR}
  echo "[CollectWgsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

  BAM=$(realpath *.bam)
  CMD="${PICARD} CollectWgsMetrics I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"
  run_cmd $CMD

  # TODO - make metrics file available as output for nextlow
  cp ${METRICS_FILE} .
fi
