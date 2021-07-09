#!/bin/bash
# Tests that retrieve_all_sample_runs workflow successfully finds projects across runs

LOCATION=$(realpath $(dirname "$0"))

RUN=ROSALIND_0001_FLOWCELL
PRJ=Project_00001
FASTQ_DIR=${LOCATION}/FASTQ
ARCHIVED_DIR=${LOCATION}/ARCHIVED
PROCESSED_SAMPLE_SHEET_DIR=${LOCATION}/SampleSheets
RUN_DIR=${FASTQ_DIR}/${RUN}
PRJ_DIR=${RUN_DIR}/${PRJ}

make_dirs() {
  mkdir -p ${FASTQ_DIR} && mkdir -p ${ARCHIVED_DIR} && mkdir -p ${PROCESSED_SAMPLE_SHEET_DIR} && mkdir -p ${PRJ_DIR}
}

clean() {
  rm -rf ${FASTQ_DIR} && rm -rf ${ARCHIVED_DIR} && rm -rf ${PROCESSED_SAMPLE_SHEET_DIR} && rm *.txt && rm *.csv
}

prj_only_in_current_run_setup() {
  touch ${RUN_DIR}/SampleSheet_210628_ROSALIND_0001_FLOWCELL.csv
  OLD_RUN_DIR=${FASTQ_DIR}/ROSALIND_0002_FLOWCELL/
  mkdir -p ${OLD_RUN_DIR}
  touch ${OLD_RUN_DIR}/SampleSheet_210621_ROSALIND_0002_FLOWCELL.csv
}

prjs_in_old_run_setup() {
  touch ${RUN_DIR}/SampleSheet_210628_ROSALIND_0001_FLOWCELL.csv
  OLD_RUN_DIR=${FASTQ_DIR}/ROSALIND_0002_FLOWCELL/
  OLD_PRJ_DIR=${OLD_RUN_DIR}/${PRJ}
  mkdir -p ${OLD_PRJ_DIR}
  touch ${OLD_RUN_DIR}/SampleSheet_210621_ROSALIND_0002_FLOWCELL.csv
}

cd ${LOCATION}
OUTPUT_SS=run_samplesheet.txt

# TEST 1 - Test when only in current run directory
make_dirs
prj_only_in_current_run_setup
DEMUXED_DIR=${RUN_DIR} FASTQ_DIR=${FASTQ_DIR} ARCHIVED_DIR=${ARCHIVED_DIR} \
  PROCESSED_SAMPLE_SHEET_DIR=${PROCESSED_SAMPLE_SHEET_DIR} RUNNAME=${RUN} ../../../templates/retrieve_all_sample_runs.sh
EXPECTED_ENTRIES=1
if [[ ${EXPECTED_ENTRIES} -eq $(cat ${OUTPUT_SS} | wc -l) ]]; then
  echo "Expected number of Entries"
else
  echo "Expected ${EXPECTED_ENTRIES} entries. Found: $(cat ${OUTPUT_SS})"
  exit 1
fi
EXPECTED_RUNS="NONE"
for expected_run in ${EXPECTED_RUNS}; do
  if [[ -z $(cat ${OUTPUT_SS} | grep ${expected_run} ) ]]; then
    echo "ERROR - Didn't find ${expected_run}"
    exit 1
  else
    echo "Found ${expected_run}"
  fi
done
clean

# TEST 2 - Test when only in legacy run directory
make_dirs
prjs_in_old_run_setup
DEMUXED_DIR=${RUN_DIR} FASTQ_DIR=${FASTQ_DIR} ARCHIVED_DIR=${ARCHIVED_DIR} \
  PROCESSED_SAMPLE_SHEET_DIR=${PROCESSED_SAMPLE_SHEET_DIR} RUNNAME=${RUN} ../../../templates/retrieve_all_sample_runs.sh
EXPECTED_ENTRIES=1
if [[ ${EXPECTED_ENTRIES} -eq $(cat ${OUTPUT_SS} | wc -l) ]]; then
  echo "Expected number of Entries"
else
  echo "Expected ${EXPECTED_ENTRIES} entries. Found: $(cat ${OUTPUT_SS})"
  exit 1
fi
EXPECTED_RUNS="ROSALIND_0002_FLOWCELL"
for expected_run in ${EXPECTED_RUNS}; do
  if [[ -z $(cat ${OUTPUT_SS} | grep ${expected_run} ) ]]; then
    echo "ERROR - Didn't find ${expected_run}"
    exit 1
  else
    echo "Found ${expected_run}"
  fi
done
clean
