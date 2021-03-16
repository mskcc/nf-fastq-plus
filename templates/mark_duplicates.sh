#!/bin/bash
# Performs an alignment on input @SAM_LIST,  if MD="yes"
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Location to copy stats to
#
#   RUN_PARAMS_FILE, space delimited k=v pairs of run parameters
#   BAM_CH, Bam files to calculate metrics on
# Nextflow Outputs:
#   MERGED_BAM, Output from Picard's MergeSamFiles

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard MarkDuplicates ..."
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

MD=$(parse_param !{RUN_PARAMS_FILE} MD)             # yes/no - must be yes for MD to run
RUNNAME=$(parse_param !{RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)
SAMPLE_TAG=$(parse_param !{RUN_PARAMS_FILE} SAMPLE_TAG) # Also the OUTPUT_ID

#   TODO - Use Each?
INPUT_BAM=$(realpath *RGP.bam)

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
MD_TAG="${RUN_TAG}___MD"
STAT_NAME="${MD_TAG}.txt"
METRICS_FILE="${METRICS_DIR}/${STAT_NAME}"
MD_BAM="${MD_TAG}.bam"

if [[ -z $(echo ${MD} | grep -i "yes") ]]; then
  NO_MD_BAM="${RUN_TAG}___NO_MD.bam"
  echo "Skipping Mark Duplicates for ${RUN_TAG} (MD: ${MD}). Creating symbolic link to input - ${NO_MD_BAM}"
  ln -s ${INPUT_BAM} ${NO_MD_BAM}
  echo "${SKIP_FILE_KEYWORD}_MD" > ${STAT_NAME}
  exit 0
fi

echo "Running MarkDuplicates (MD: ${MD}): ${MD_TAG}. Writing to ${METRICS_DIR}"
CMD="!{PICARD} MarkDuplicates CREATE_INDEX=true METRICS_FILE=${METRICS_FILE} OUTPUT=${MD_BAM} INPUT=${INPUT_BAM}"
run_cmd $CMD

# TODO - make metrics file available as output for nextlow
cp ${METRICS_FILE} .
