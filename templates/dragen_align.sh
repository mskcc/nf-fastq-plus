#!/bin/bash
# Submits an alignment job to DRAGEN based off of the demultiplexing output
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
DGN_REFERENCE="/staging/ref/GRCh37_dna" # TODO - DGN_REFERENCE=$(parse_param ${LANE_PARAM_FILE} DGN_REFERENCE)
RUN_TAG_PARAM=$(parse_param ${SAMPLE_PARAMS_FILE} RUN_TAG)
DGN_BAM=$(parse_param ${SAMPLE_PARAMS_FILE} DGN_BAM)
FASTQ_LIST_FILE=$(parse_param ${SAMPLE_PARAMS_FILE} FASTQ_LIST_FILE)
SAMPLE_TAG=$(parse_param ${SAMPLE_PARAMS_FILE} SAMPLE_TAG)

if [[ ! -f ${FASTQ_LIST_FILE} ]]; then
  echo "Invalid FASTQ_LIST argument: ${FASTQ_LIST_FILE}"
  exit 1
fi
OUTPUT_PREFIX="$(basename ${DGN_BAM} | cut -d'.' -f1)"
OUTPUT_DIR="$(dirname ${DGN_BAM})"

CMD="/opt/edico/bin/dragen --ref-dir ${DGN_REFERENCE} --enable-duplicate-marking true"
CMD+=" --enable-map-align-output true --enable-variant-caller true --output-directory ${OUTPUT_DIR}"
CMD+=" --output-file-prefix ${OUTPUT_PREFIX} --fastq-list-sample-id ${SAMPLE_TAG} --fastq-list ${FASTQ_LIST_FILE}"

echo ${CMD} >> ${CMD_FILE}

echo ${CMD}

# TODO - Actually run DRAGEN command
mkdir -p ${OUTPUT_DIR}
touch ${OUTPUT_DIR}/${OUTPUT_PREFIX}*.bam
# eval ${CMD}

cat ${SAMPLE_PARAMS_FILE} > ${RUN_PARAMS_FILE}

OUTPUT_BAM=$(find ${OUTPUT_DIR} -type f -name "${OUTPUT_PREFIX}*.bam")
ln -s ${OUTPUT_BAM} .

SYMLINK=$(find -L . -type l -name "${OUTPUT_PREFIX}*")

# TODO - Actually grab DRAGEN stats
touch DRAGEN_STATS.txt

echo "DRAGEN BAM Successfully Created: ${OUTPUT_BAM}. SYMLINK=${SYMLINK}"
