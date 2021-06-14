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

# Write to local directory unless these parameters are passed in
if [[ -z ${STATSDONEDIR} || -z ${STATS_DIR} ]]; then
  STATSDONEDIR="."
  STATS_DIR="."
fi

MD=$(parse_param ${RUN_PARAMS_FILE} MD)             # yes/no - must be yes for MD to run
RUNNAME=$(parse_param ${RUN_PARAMS_FILE} RUNNAME)
RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG) # Also the OUTPUT_ID
FINAL_BAM=$(parse_param ${RUN_PARAMS_FILE} FINAL_BAM)

MACHINE=$(echo $RUNNAME | cut -d'_' -f1)

BAM_PATTERN="___MRG.bam"
INPUT_BAM=$(realpath *${BAM_PATTERN})

METRICS_DIR=${STATSDONEDIR}/${MACHINE}  # Location of metrics & BAMs
BAM_DIR=${STATS_DIR}/${RUNNAME}          # Specific path to BAMs
mkdir -p ${METRICS_DIR}
mkdir -p ${BAM_DIR}

MD_TAG="${RUN_TAG}___MD"
STAT_FILE_NAME="${MD_TAG}.txt"

OUTPUT_BAM=""
if [[ -z $(echo ${MD} | grep -i "yes") ]]; then
  ORIGINAL_BAM=$(realpath ${INPUT_BAM})

  MSG="Skipping Mark Duplicates for ${RUN_TAG} (MD: ${MD}). Passing on Merged BAM: ${INPUT_BAM} => ${ORIGINAL_BAM} => ${FINAL_BAM}"
  echo ${MSG}
  echo ${MSG} > ${STAT_FILE_NAME}

  # We move the Merged BAM to its delivey location because we are not running MarkDuplicates
  mv ${ORIGINAL_BAM} ${FINAL_BAM}

  # NOTE - DO NOT EXIT (e.g. "exit 0") Module mark_duplicates outputs ENV varialbes and to do this nextflow will append
  # statements to write all environment variables to .command.env AT FILE END
  #   e.g. echo SAMPLE_TAG=$SAMPLE_TAG > .command.env
  # If you exit here, then .command.env will never be written
else
  METRICS_FILE="${METRICS_DIR}/${STAT_FILE_NAME}"

  echo "Running MarkDuplicates (MD: ${MD}): ${MD_TAG}. Writing to ${METRICS_DIR}"
  CMD="${PICARD} MarkDuplicates CREATE_INDEX=true METRICS_FILE=${METRICS_FILE} OUTPUT=${FINAL_BAM} INPUT=${INPUT_BAM}"
  run_cmd $CMD

  # TODO - DELETE THIS?
  cp ${METRICS_FILE} .
fi

LINKED_BAM="STATS___$(basename ${INPUT_BAM})"
echo "Linking ${OUTPUT_BAM} to ${LINKED_BAM}"

# Check BAM was moved and provide a symbolic link to continue nextflow pipeline if successful
ln -s ${FINAL_BAM} ${LINKED_BAM}
