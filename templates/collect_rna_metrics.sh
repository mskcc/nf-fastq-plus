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

RIBO_INTER=$(parse_param !{RUN_PARAMS_FILE} RIBO_INTER)
REF_FLAT=$(parse_param !{RUN_PARAMS_FILE} REF_FLAT)
RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

# Skip if no valid BAITS/TARGETS or MSKQ=no
if [[ ! -f ${RIBO_INTER} || ! -f ${REF_FLAT} ]]; then
  echo "Skipping CollectRnaSeqMetrics for ${RUN_TAG} (RIBO_INTER: ${RIBO_INTER}, REF_FLAT: ${REF_FLAT})"
  exit 0
fi

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
METRICS_FILE="${METRICS_DIR}/${RUN_TAG}___RNA.txt"
echo "[CollectRnaSeqMetrics:${RUN_TAG}] Writing to ${METRICS_FILE}"

BAM=$(ls *.bam)
CMD="!{PICARD} CollectRnaSeqMetrics RIBOSOMAL_INTERVALS=${RIBO_INTER} STRAND_SPECIFICITY=NONE REF_FLAT=${REF_FLAT} I=${BAM} O=${METRICS_FILE}"
run_cmd $CMD
