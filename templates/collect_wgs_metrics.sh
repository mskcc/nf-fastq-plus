#!/bin/bash
# Runs Picard's CollectWgsMetrics 
# Nextflow Inputs:
#   RUN_PARAMS_FILE, path - file w/ k=v pairs of parameters
#   BAM_CH, path - BAM file to analyz
#   STATSDONEDIR, env - Where to write stats
#
#   (config)
#   PICARD,     Picard Command
# Nextflow Outputs:
#   None

#########################################
# Executes and logs command. Exits script if there is an errro
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD} >> ${CMD_FILE}
  eval ${INPUT_CMD}

  # We exit the script w/ the exit code (this is to capture out-of-memory errors)
  exit_code=$?
  if [[ ${exit_code} -ne 0 ]]; then
    exit ${exit_code}
  fi
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
mkdir -p ${METRICS_DIR}
STATS_FILENAME="${RUN_TAG}___WGS.txt"

WGS_GENOMES="mm10\|wgs\|hg19\|grch37\|grch38"
if [ -z $(echo $GTAG | grep -i ${WGS_GENOMES}) ]; then
  MSG="Skipping CollectWgsMetrics for ${RUN_TAG}. GTAG (${GTAG}) not present in ${WGS_GENOMES} (TYPE: ${TYPE})";
  echo $MSG > ${STATS_FILENAME}
elif [ "${TYPE}" != "WGS" ]; then
  MSG="Skipping CollectWgsMetrics for ${RUN_TAG}. TYPE: ${TYPE} != WGS (GTAG: ${GTAG})"
  echo $MSG > ${STATS_FILENAME}
else
  METRICS_FILE="${METRICS_DIR}/${STATS_FILENAME}"
  echo "[CollectWgsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

  BAM=$(realpath *.bam)
  CMD="${PICARD} CollectWgsMetrics I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"
  run_cmd $CMD

  # TODO - make metrics file available as output for nextlow
  cp ${METRICS_FILE} .
fi
