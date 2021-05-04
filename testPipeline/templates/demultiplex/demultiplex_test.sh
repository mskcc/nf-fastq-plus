#!/bin/bash

LOCATION=$(dirname "$0")
cd ${LOCATION}

TYPE=no_mask
echo "${TYPE}"
FASTQ_DIR=${TYPE}_FASTQ
mkdir -p ${FASTQ_DIR}
OUT=${FASTQ_DIR}
CMD_FILE=${FASTQ_DIR}/CMD_FILE.txt
DEMUX_FILE=${FASTQ_DIR}/DEMUX_LOG_FILE.txt
OUT_FILE=${FASTQ_DIR}/${TYPE}.txt
SAMPLESHEET=$(realpath ../../bin/test/data/split_sampleSheet/split/SampleSheet_210421_ROSALIND_0004_FLOWCELLNAME.csv) \
  RUN_TO_DEMUX_DIR=210421_ROSALIND_0004_FLOWCELLNAME \
  BCL2FASTQ=/bin/echo \
  CELL_RANGER_ATAC=TODO \
  DEMUX_ALL=false \
  FASTQ_DIR=$FASTQ_DIR \
  DATA_TEAM_EMAIL=none \
  CMD_FILE=${CMD_FILE} \
  DEMUX_LOG_FILE=${DEMUX_FILE} \
  ../../templates/demultiplex.sh > ${OUT_FILE}
incorrect_mask="use-bases-mask"
ls ${OUT_FILE}
has_mask=$(cat ${OUT_FILE} | grep "${incorrect_mask}")
if [[ ! -z ${has_mask} ]]; then
  echo "[ERROR] Mask was applied: ${has_mask}"
  exit 1
else
  echo "${TYPE} - Correct mask: ${incorrect_mask}"
  rm -rf ${FASTQ_DIR}
fi

TYPE=6nt_test
echo "${TYPE}"
FASTQ_DIR=${TYPE}_FASTQ
mkdir -p ${FASTQ_DIR}
OUT=${FASTQ_DIR}
CMD_FILE=${FASTQ_DIR}/CMD_FILE.txt
DEMUX_FILE=${FASTQ_DIR}/DEMUX_LOG_FILE.txt
OUT_FILE=${FASTQ_DIR}/${TYPE}.txt
SAMPLESHEET=$(realpath ../../bin/test/data/split_sampleSheet/split/SampleSheet_210421_ROSALIND_0004_FLOWCELLNAME_6nt.csv) \
  RUN_TO_DEMUX_DIR=210421_ROSALIND_0004_FLOWCELLNAME \
  BCL2FASTQ=/bin/echo \
  CELL_RANGER_ATAC=TODO \
  DEMUX_ALL=false \
  FASTQ_DIR=$FASTQ_DIR \
  DATA_TEAM_EMAIL=none \
  CMD_FILE=${CMD_FILE} \
  DEMUX_LOG_FILE=${DEMUX_FILE} \
  ../../templates/demultiplex.sh > ${OUT_FILE}
expected_mask="use-bases-mask y50n,i6n2,n8,y50n"
has_mask=$(cat ${OUT_FILE} | grep "${expected_mask}")
if [[ ! -z ${has_mask} ]]; then
  echo "${TYPE} - Correct mask: ${expected_mask}"
  rm -rf ${FASTQ_DIR}
else
  echo "[ERROR] Did not have mask:  ${expected_mask}"
  exit 1
fi

TYPE=i7_test
echo "${TYPE}"
FASTQ_DIR=${TYPE}_FASTQ
mkdir -p ${FASTQ_DIR}
OUT=${FASTQ_DIR}
CMD_FILE=${FASTQ_DIR}/CMD_FILE.txt
DEMUX_FILE=${FASTQ_DIR}/DEMUX_LOG_FILE.txt
OUT_FILE=${FASTQ_DIR}/${TYPE}.txt
SAMPLESHEET=$(realpath ../../bin/test/data/split_sampleSheet/split/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME_i7.csv) \
  RUN_TO_DEMUX_DIR=210421_ROSALIND_0004_FLOWCELLNAME \
  BCL2FASTQ=/bin/echo \
  CELL_RANGER_ATAC=TODO \
  DEMUX_ALL=false \
  FASTQ_DIR=$FASTQ_DIR \
  DATA_TEAM_EMAIL=none \
  CMD_FILE=${CMD_FILE} \
  DEMUX_LOG_FILE=${DEMUX_FILE} \
  ../../templates/demultiplex.sh > ${OUT_FILE}
expected_mask="use-bases-mask y50n,i8,n8,y50n"
has_mask=$(cat ${OUT_FILE} | grep "${expected_mask}")
if [[ ! -z ${has_mask} ]]; then
  echo "${TYPE} - Correct mask: ${expected_mask}"
  rm -rf ${FASTQ_DIR}
else
  echo "[ERROR] Did not have mask:  ${expected_mask}"
  exit 1
fi

TYPE=DLP_test
echo "${TYPE}"
FASTQ_DIR=${TYPE}_FASTQ
mkdir -p ${FASTQ_DIR}
OUT=${FASTQ_DIR}
CMD_FILE=${FASTQ_DIR}/CMD_FILE.txt
DEMUX_FILE=${FASTQ_DIR}/DEMUX_LOG_FILE.txt
OUT_FILE=${FASTQ_DIR}/${TYPE}.txt
SAMPLESHEET=$(realpath ../../bin/test/data/split_sampleSheet/split/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME_DLP.csv) \
  RUN_TO_DEMUX_DIR=210421_ROSALIND_0004_FLOWCELLNAME \
  BCL2FASTQ=/bin/echo \
  CELL_RANGER_ATAC=TODO \
  DEMUX_ALL=false \
  FASTQ_DIR=$FASTQ_DIR \
  DATA_TEAM_EMAIL=none \
  CMD_FILE=${CMD_FILE} \
  DEMUX_LOG_FILE=${DEMUX_FILE} \
  ../../templates/demultiplex.sh > ${OUT_FILE}
expected_lane_split="no-lane-splitting"
has_mask=$(cat ${OUT_FILE} | grep "${expected_lane_split}")
if [[ ! -z ${has_mask} ]]; then
  echo "${TYPE} - Correct lane splitting: ${expected_lane_split}"
  rm -rf ${FASTQ_DIR}
else
  echo "[ERROR] Did not have ${expected_lane_split}"
  exit 1
fi

rm bcl2fastq.log
