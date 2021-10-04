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
#################################################################
##### Step 1) Parse out params from input sample_params.txt #####
#################################################################
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG) # Also the OUTPUT_ID
RECIPE=$(parse_param ${RUN_PARAMS_FILE} RECIPE)
RUN_TAG=$(parse_param ${RUN_PARAMS_FILE} RUN_TAG)
PROJECT_TAG=$(parse_param ${RUN_PARAMS_FILE} PROJECT_TAG)

CRISPRESSO_OUTPUT_DIR=${STATSDONEDIR}/CRISPRESSO/${PROJECT_TAG}   # Where CRISPRESSO results will be written

#################################################################
#####     Step 2) Perform validation/error-checking         #####
#################################################################
# Check 1 - Only run for "CRISPRSeq"
TARGET_RECIPE="CRISPRSeq"
if [[ ${RECIPE} != ${TARGET_RECIPE} ]]; then
  echo "Not a ${TARGET_RECIPE}. Skipping..."
  exit 0
fi
# Check 2 - Check for only one CRISPRESS input directory & error if not, i.e. NUM_DIRS != 1
EXCEL_PROJECT_DIRNAME=$(echo ${PROJECT_TAG}| sed 's/^P//g')
echo "Searching ${CRISPRESSO_EXCEL_INPUT_DIR} for project excel: ${EXCEL_PROJECT_DIRNAME}"
PROJECT_DIR=$(find ${CRISPRESSO_EXCEL_INPUT_DIR} -type d -name "${EXCEL_PROJECT_DIRNAME}")
mkdir -p ${CRISPRESSO_OUTPUT_DIR}
NUM_DIRS=$(echo ${PROJECT_DIR} | tr ' ' '\n' | wc -l)
# Check dirs
if [[ ${NUM_DIRS} -ne 1 ]]; then
  if [[ -f ${CRISPRESSO_OUTPUT_DIR}/checked.txt ]]; then
    echo "Already sent email for missing ${CRISPRESSO_OUTPUT_DIR} - not sending"
    exit 0
  else
    subj="[ACTION REQUIRED] Resolve Crispresso for Project ${CRISPRESSO_OUTPUT_DIR}"
    body="Identified more than one directory for ${CRISPRESSO_OUTPUT_DIR} in ${CRISPRESSO_EXCEL_INPUT_DIR}"
    echo ${body} | mail -s "${subj}" ${DATA_TEAM_EMAIL}
    touch ${CRISPRESSO_OUTPUT_DIR}/checked.txt
  fi
fi
# Check 3 - Check for only one EXCEL input file
EXCEL_FILE=${PROJECT_DIR}/*.xslx
NUM_EXCELS=$(echo ${EXCEL_FILE} | tr ' ' '\n' | wc -l)
EXCEL_CHECKED_FILE=${CRISPRESSO_OUTPUT_DIR}/checked_excel.txt
if [[ ${NUM_EXCELS} -ne 1 ]]; then
  if [[ -f ${EXCEL_CHECKED_FILE} ]]; then
    echo "Already sent email for ambiguous excel ${CRISPRESSO_OUTPUT_DIR} - not sending"
    exit 0
  else
    subj="[ACTION REQUIRED] Ambiguous Crispresso Excel for Project ${CRISPRESSO_OUTPUT_DIR} (Number: ${NUM_EXCELS})"
    body="Identified more than one crispresso excel for ${CRISPRESSO_OUTPUT_DIR} in ${CRISPRESSO_EXCEL_INPUT_DIR}: ${EXCEL_FILE}"
    echo ${body} | mail -s "${subj}" ${DATA_TEAM_EMAIL}
    touch ${EXCEL_CHECKED_FILE}
  fi
fi

#################################################################
##### Step 3) Run Command - either Picard or python script  #####
#################################################################
echo "Running Crispresso on ${CRISPRESSO_OUTPUT_DIR}. Writing to ${CRISPRESSO_OUTPUT_DIR}"
RunCrisprAnalysis_REMIX.py -run ${RUN_TAG} \
  -proj ${CRISPRESSO_OUTPUT_DIR} \
  -edir ${CRISPRESSO_EXCEL_INPUT_DIR} \
  -fdir ${FASTQ_DIR} \
  -outdir ${CRISPRESSO_OUTPUT_DIR}
