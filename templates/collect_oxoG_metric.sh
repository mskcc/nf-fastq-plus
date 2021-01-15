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

BAITS=$(parse_param !{RUN_PARAMS_FILE} BAITS)
TARGETS=$(parse_param !{RUN_PARAMS_FILE} TARGETS)
MSKQ=$(parse_param !{RUN_PARAMS_FILE} MSKQ)
REFERENCE=$(parse_param !{RUN_PARAMS_FILE} REFERENCE)
RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

# Skip if no valid BAITS/TARGETS or MSKQ=no
if [[ ! -f ${BAITS} || ! -f ${TARGETS} || -z $(echo $MSKQ | grep -i "yes") ]]; then
  echo "Skipping CollectOxoGMetrics for ${RUN_TAG} (BAITS: ${BAITS}, TARGETS: ${TARGETS} MSKQ: ${MSKQ})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___oxoG.txt"
echo "[CollectOxoGMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectOxoGMetrics CONTEXT_SIZE=0 I=${BAM} O=${METRICS_FILE} R=${REFERENCE}"

run_cmd $CMD
