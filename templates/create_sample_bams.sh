#!/bin/bash
# Finds and merges all sample BAMs
# Nextflow Inputs:
#   TODO
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

# Import utils
LOCATION=$0
TEMPLATE_DIR=$(dirname $LOCATION)
source ${TEMPLATE_DIR}/utils/utils.sh

SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)

# Retrieve all the samplesheets that contain this sample
SAMPLE_SHEETS=$(find ${LAB_SAMPLE_SHEET_DIR} -type f -name "SampleSheet*" -exec grep -l "\d,[A-Za-z_]*${SAMPLE_TAG},.*${PROJECT_TAG}" \;)

# TODO - verify this
