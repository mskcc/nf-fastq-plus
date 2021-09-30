#!/bin/bash
# Runs crispresso per sample
# Nextflow Inputs:
#   RUN_PARAMS_FILE, path - file w/ k=v pairs of parameters
#
#   (config)
#   CRISPRESSO_EXCEL_INPUT_DIR,           directory w/ CRISPRESSO excel files
# Nextflow Outputs:
#   STATSDONEDIR

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

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2 | sort | uniq
}

SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG) # Also the OUTPUT_ID
RECIPE=$(parse_param ${LANE_PARAM_FILE} RECIPE)


RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
PROJECT_TAG=$(parse_param ${LANE_PARAM_FILE} PROJECT_TAG)


TARGET_RECIPE="CRISPRSeq"
if [[ ${RECIPE} != ${TARGET_RECIPE} ]]; then
  echo "Not a ${TARGET_RECIPE}. Skipping..."
  exit 0
fi

# Find crispresso excel if it exists
echo "Searching ${CRISPRESSO_EXCEL_INPUT_DIR} for project excel..."
PROJECT_DIR=$(find ${CRISPRESSO_EXCEL_INPUT_DIR} -type d -name "${PROJECT_TAG}")

# Check for only one directory and error if  NUM_DIRS != 1
NUM_DIRS=$(echo ${PROJECT_DIR} | tr ' ' '\n' | wc -l)

CRISPRESSO_OUTPUT_DIR=${STATSDONEDIR}/CRISPRESSO/${PROJECT_TAG}   # Where CRISPRESSO results will be written
mkdir -p ${CRISPRESSO_DIR}

# Check dirs
if [[ ${NUM_DIRS} -ne 1 ]]; then
  if [[ -f ${CRISPRESSO_DIR}/checked.txt ]]; then
    echo "Already sent email for missing ${PROJECT_TAG} - not sending"
    exit 0
  else
    subj="[ACTION REQUIRED] Resolve Crispresso for Project ${PROJECT_TAG}"
    body="Identified more than one directory for ${PROJECT_TAG} in ${CRISPRESSO_EXCEL_INPUT_DIR}"
    echo ${body} | mail -s "${subj}" ${DATA_TEAM_EMAIL}
    touch ${CRISPRESSO_DIR}/checked.txt
  fi
fi

# Grab excel file
EXCEL_FILE=${PROJECT_DIR}/*.xslx
NUM_EXCELS=$(echo ${EXCEL_FILE} | tr ' ' '\n' | wc -l)
if [[ ${NUM_EXCELS} -ne 1 ]]; then

fi
# TODO - error if more than one excel


# TODO - parse excel
# TODO - verify ampliconSeq & 

echo "Running Crispresso on ${PROJECT_TAG}. Writing to ${CRISPRESSO_DIR}"
cd ${CRISPRESSO_OUTPUT_DIR}
RunCrisprAnalysis_REMIX.py --run ${RUN_TAG} --proj ${PROJECT_TAG} --edir ${CRISPRESSO_EXCEL_INPUT_DIR}
