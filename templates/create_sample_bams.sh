#!/bin/bash
# Finds and merges all sample BAMs
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

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

SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)

# Retrieve all the samplesheets that contain this sample
SAMPLE_SHEETS=$(find ${LAB_SAMPLE_SHEET_DIR} -type f -name "SampleSheet*" -exec grep -l "\d,[A-Za-z_]*${SAMPLE_TAG},.*${PROJECT_TAG}" \;)

# TODO - verify this
