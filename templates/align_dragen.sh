#!/bin/bash
# Submits an alignment job to DRAGEN based off of the demultiplexing output of a DRAGEN demultiplex job
# Nextflow Inputs:
#   RUN_PARAMS_FILE, env - The suffix of the files we care about
# Nextflow Outputs:
#   CMD_FILE, path - where to log all commands to
#   RUN_PARAMS_FILE, file - Output all individual param files
#   SAM_CH, Outputs SAM w/ Readgroups (*.sam)

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

SAMPLE_PARAMS_FILE=$(ls *${RUN_PARAMS_FILE})
echo "SAMPLE_PARAMS_FILE=${SAMPLE_PARAMS_FILE}"
DGN_REFERENCE=$(parse_param ${SAMPLE_PARAMS_FILE} DGN_REFERENCE)
RUN_TAG_PARAM=$(parse_param ${SAMPLE_PARAMS_FILE} RUN_TAG)
FINAL_BAM=$(parse_param ${SAMPLE_PARAMS_FILE} FINAL_BAM)
FASTQ_LIST_FILE=$(parse_param ${SAMPLE_PARAMS_FILE} FASTQ_LIST_FILE)
SAMPLE_TAG=$(parse_param ${SAMPLE_PARAMS_FILE} SAMPLE_TAG)

if [[ ! -f ${FASTQ_LIST_FILE} ]]; then
  echo "Invalid FASTQ_LIST argument: ${FASTQ_LIST_FILE}"
  exit 1
fi
OUTPUT_PREFIX="$(basename ${FINAL_BAM} | cut -d'.' -f1)"
OUTPUT_DIR="$(dirname ${FINAL_BAM})"
mkdir -p ${OUTPUT_DIR}

OUTPUT_BAM=$(find ${OUTPUT_DIR} -type f -name "${OUTPUT_PREFIX}*.bam")
if [[ -f ${OUTPUT_BAM} ]]; then
  echo "Skipping DRAGEN alignment. BAM already created for ${SAMPLE_TAG}: ${OUTPUT_BAM}" 
else
  CMD="/opt/edico/bin/dragen --ref-dir ${DGN_REFERENCE} --enable-duplicate-marking true --intermediate-results-dir /staging/temp"
  CMD+=" --enable-map-align-output true --enable-variant-caller true --output-directory ${OUTPUT_DIR}"
  CMD+=" --output-file-prefix ${OUTPUT_PREFIX} --fastq-list-sample-id ${SAMPLE_TAG} --fastq-list ${FASTQ_LIST_FILE}"

  run_cmd "${CMD}"

  OUTPUT_BAM=$(find ${OUTPUT_DIR} -type f -name "${OUTPUT_PREFIX}*.bam")
fi

run_cmd "cat ${SAMPLE_PARAMS_FILE} > ${RUN_PARAMS_FILE}"

ln -s ${OUTPUT_BAM} .
SYMLINK=$(find -L . -type l -name "${OUTPUT_PREFIX}*")

echo "DRAGEN BAM Successfully Created: ${OUTPUT_BAM}. SYMLINK=${SYMLINK}"
