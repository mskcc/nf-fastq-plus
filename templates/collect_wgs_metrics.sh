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

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard CollectAlignmentSummaryMetrics ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}
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

GTAG=$(parse_param !{RUN_PARAMS_FILE} GTAG)
TYPE=$(parse_param !{RUN_PARAMS_FILE} TYPE)
REFERENCE=$(parse_param !{RUN_PARAMS_FILE} REFERENCE)
RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

WGS_GENOMES="mm10\|wgs\|hg19\|grch37"
if [ -z $(echo $GTAG | grep -i ${WGS_GENOMES}) ]; then 
  echo "Skipping CollectWgsMetrics for ${RUN_TAG}. GTAG (${GTAG}) not present in ${WGS_GENOMES} (TYPE: ${TYPE})";
  exit 0
fi

if [ "${TYPE^^}" != "WGS" ]; then 
  echo "Skipping CollectWgsMetrics for ${RUN_TAG}. TYPE: ${TYPE} != WGS (GTAG: ${GTAG})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___WGS.txt"
echo "[CollectWgsMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectWgsMetrics I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"
run_cmd $CMD
