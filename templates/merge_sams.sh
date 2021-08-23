#!/bin/bash
# Performs an alignment on input @SAM_LIST
# Nextflow Inputs:
#   PICARD,     Picard Command
#
#   RUN_PARAMS_FILE, space delimited k=v pairs of run parameters
#   BAM_CH, Bam files to calculate metrics on
# Nextflow Outputs:
#   MERGED_BAM, Output from Picard's MergeSamFiles

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

if [[ -z ${STATS_DIR} ]]; then
  STATS_DIR="."
fi

RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
MD=$(parse_param ${RUN_PARAMS_FILE} MD)             # yes/no - must be yes for MD to run

SAMS=$(realpath *.sam)
NUM_SAMS=$(echo $SAMS | tr ' ' '\n' | wc -l)

if [[ -z $(echo ${MD} | grep -i "yes") ]]; then
  DELIVERED_BAM_DIR=${STATS_DIR}/${RUNNAME}
  MERGED_BAM="${DELIVERED_BAM_DIR}/${RUN_TAG}___MRG.bam"

  echo "Writing BAM directly to delivered directory: ${DELIVERED_BAM_DIR}"
  mkdir -p ${DELIVERED_BAM_DIR}
  touch ${MERGED_BAM}

  ln ${MERGED_BAM} .
else
  echo "Passing BAM for mark duplicates, which will be the delivered BAM"
  MERGED_BAM="${RUN_TAG}___MRG.bam"
fi

echo "Merging ${NUM_SAMS} SAM(s): ${MERGED_BAM}"

MERGE_CMD="${PICARD} MergeSamFiles CREATE_INDEX=true O=${MERGED_BAM}"
for SAM in $SAMS; do
  MERGE_CMD="${MERGE_CMD} I=${SAM}"
done

run_cmd $MERGE_CMD
