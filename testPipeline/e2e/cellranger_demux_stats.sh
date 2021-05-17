#!/bin/bash

# Reference - https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/using/mkfastq

LOCATION=$(realpath $(dirname "$0"))
RUN=200514_ROSALIND_0001_FLOWCELL

TEST_OUTPUT=${LOCATION}/main_test

FASTQ_DIR=${TEST_OUTPUT}/FASTQ
STATS_DIR=${TEST_OUTPUT}/STATS_DIR
SEQUENCER_DIR=${TEST_OUTPUT}/sequencers
LAB_SAMPLE_SHEET_DIR=${TEST_OUTPUT}/LIMS_SampleSheets
PROCESSED_SAMPLE_SHEET_DIR="${TEST_OUTPUT}/DividedSampleSheets"
COPIED_SAMPLE_SHEET_DIR="${TEST_OUTPUT}/SampleSheetCopies"
STATSDONEDIR="${STATS_DIR}/DONE"

mkdir -p ${FASTQ_DIR}
mkdir -p ${STATS_DIR}
mkdir -p ${SEQUENCER_DIR}
mkdir -p ${LAB_SAMPLE_SHEET_DIR}
mkdir -p ${PROCESSED_SAMPLE_SHEET_DIR}
mkdir -p ${COPIED_SAMPLE_SHEET_DIR}
mkdir -p ${STATSDONEDIR}

LOG_DIR=${TEST_OUTPUT}/logs
mkdir -p ${LOG_DIR}
LOG_FILE="${LOG_DIR}/nf_fastq_run.log"
CMD_FILE="${LOG_DIR}/commands.log"
DEMUX_LOG_FILE="${LOG_DIR}/bcl2fastq.log"

TEST_NEXTFLOW_CONFIG=${LOCATION}/nextflow.config

# Create a basic samplesheet
printf "Lane,Sample,Index\n1,test_sample,SI-TT-D9\n" > ${LAB_SAMPLE_SHEET_DIR}/SampleSheet_${RUN}.csv

# Create nextflow config that 1) runs locally, 2) Has relative directory paths, 3) Has Docker images
cat ${LOCATION}/../../nextflow.config | sed -n '/env {/,$p' \
  | sed -E "s#BWA=.*#BWA=\"/usr/gitc/bwa\"#" \
  | sed -E "s#PICARD=.*#PICARD=\"java -jar /usr/gitc/picard.jar\"#" \
  | sed -E "s#FASTQ_DIR=.*#FASTQ_DIR=\"${FASTQ_DIR}\"#" \
  | sed -E "s#STATS_DIR=.*#STATS_DIR=\"${STATS_DIR}\"#" \
  | sed -E "s#SEQUENCER_DIR=.*#SEQUENCER_DIR=\"${SEQUENCER_DIR}\"#" \
  | sed -E "s#LAB_SAMPLE_SHEET_DIR=.*#LAB_SAMPLE_SHEET_DIR=\"${LAB_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#PROCESSED_SAMPLE_SHEET_DIR=.*#PROCESSED_SAMPLE_SHEET_DIR=\"${PROCESSED_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#COPIED_SAMPLE_SHEET_DIR=.*#COPIED_SAMPLE_SHEET_DIR=\"${COPIED_SAMPLE_SHEET_DIR}\"#" \
  | sed -E "s#STATSDONEDIR=.*#STATSDONEDIR=\"${STATSDONEDIR}\"#" \
  | sed -E "s#LOG_FILE=.*#LOG_FILE=\"${LOG_FILE}\"#" \
  | sed -E "s#CMD_FILE=.*#CMD_FILE=\"${CMD_FILE}\"#" \
  | sed -E "s#DEMUX_LOG_FILE=.*#DEMUX_LOG_FILE=\"${DEMUX_LOG_FILE}\"#" \
  > ${TEST_NEXTFLOW_CONFIG}

  # | sed -E "s#=.*#=\"${}\"#" \

# Download raw cellranger BCL files
wget https://cf.10xgenomics.com/supp/cell-exp/cellranger-tiny-bcl-1.2.0.tar.gz

# Unpack the files
TEST_MACHINE_DIR=${SEQUENCER_DIR}/rosalind
TEST_BCL_DIR=${TEST_MACHINE_DIR}/${RUN}
mkdir -p ${TEST_MACHINE_DIR}
tar -zxvf cellranger-tiny-bcl-1.2.0.tar.gz -C ${TEST_MACHINE_DIR}
mv ${TEST_MACHINE_DIR}/cellranger-tiny-bcl-1.2.0 ${TEST_BCL_DIR}

RUN_OUT=${RUN}.out
CMD="nextflow ${LOCATION}/../../main.nf -c ${TEST_NEXTFLOW_CONFIG} --run ${RUN}" # > ${RUN_OUT}"
echo $CMD
eval $CMD
