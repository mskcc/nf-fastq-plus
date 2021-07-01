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

simple_test_setup() {
  touch ${RUN_DIR}/SampleSheet_210628_ROSALIND_0001_FLOWCELL.csv
  OLD_RUN_DIR=${FASTQ_DIR}/ROSALIND_0002_FLOWCELL/
  OLD_PRJ_DIR=${OLD_RUN_DIR}/${PRJ}
  mkdir -p ${OLD_PRJ_DIR}
  touch ${OLD_RUN_DIR}/SampleSheet_210621_ROSALIND_0002_FLOWCELL.csv
}

cd ${LOCATION}
make_dirs
simple_test_setup
DEMUXED_DIR=${RUN_DIR} FASTQ_DIR=${FASTQ_DIR} ARCHIVED_DIR=${ARCHIVED_DIR} \
  PROCESSED_SAMPLE_SHEET_DIR=${PROCESSED_SAMPLE_SHEET_DIR} RUNNAME=${RUN} ../../../templates/retrieve_all_sample_runs.sh

OUTPUT_SS=run_samplesheet.txt

EXPECTED_ENTRIES=2
if [[ ${EXPECTED_ENTRIES} -eq $(cat ${OUTPUT_SS} | wc -l) ]]; then
  echo "Expected number of Entries"
else
  echo "Expected ${EXPECTED_ENTRIES} entries. Found: $(cat ${OUTPUT_SS})"
  exit 1
fi

EXPECTED_RUNS="ROSALIND_0001_FLOWCELL ROSALIND_0002_FLOWCELL"
for expected_run in ${EXPECTED_RUNS}; do
  if [[ -z $(cat ${OUTPUT_SS} | grep ${expected_run} ) ]]; then
    echo "ERROR - Didn't find ${expected_run}"
    exit 1
  else
    echo "Found ${expected_run}"
  fi
done
clean




