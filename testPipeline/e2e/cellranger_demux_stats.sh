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
SAMPLE_SHEET=${LAB_SAMPLE_SHEET_DIR}/SampleSheet_${RUN}.csv
echo "[Header],,,,,,,," > ${SAMPLE_SHEET}
echo "IEMFileVersion,4,,,,,,," >> ${SAMPLE_SHEET}
echo "Date,5/10/2021,,,,,,," >> ${SAMPLE_SHEET}
echo "Workflow,GenerateFASTQ,,,,,,," >> ${SAMPLE_SHEET}
echo "Application,MICHELLE,,,,,,," >> ${SAMPLE_SHEET}
echo "Assay,,,,,,,," >> ${SAMPLE_SHEET}
echo "Description,,,,,,,," >> ${SAMPLE_SHEET}
echo "Chemistry,Default,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Reads],,,,,,,," >> ${SAMPLE_SHEET}
echo "27,,,,,,,," >> ${SAMPLE_SHEET}
echo "91,,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Settings],,,,,,,," >> ${SAMPLE_SHEET}
echo "Adapter,,,,,,,," >> ${SAMPLE_SHEET}
echo ",,,,,,,," >> ${SAMPLE_SHEET}
echo "[Data],,,,,,,," >> ${SAMPLE_SHEET}
echo "Lane,Sample_ID,Sample_Name,Sample_Plate,Sample_Well,I7_Index_ID,index,Sample_Project,Description" >> ${SAMPLE_SHEET}
echo "1,test_sample,test_sample,Human,10X_Genomics_GeneExpression,SI-TT-D9,Project_10001,Investigator_1" >> ${SAMPLE_SHEET}

# Create nextflow config that 1) runs locally, 2) Has relative directory paths, 3) Has Docker images
echo "executor {" > ${TEST_NEXTFLOW_CONFIG}
echo "  name = 'local'" >> ${TEST_NEXTFLOW_CONFIG}
echo "  perJobMemLimit = true" >> ${TEST_NEXTFLOW_CONFIG}
echo "  scratch = true" >> ${TEST_NEXTFLOW_CONFIG}
echo "  TMPDIR = '/scratch'" >> ${TEST_NEXTFLOW_CONFIG}
echo "}" >> ${TEST_NEXTFLOW_CONFIG}
cat ${LOCATION}/../../nextflow.config | sed -n '/env {/,$p' \
  | sed -E "s#BWA=.*#BWA=\"/usr/gitc/bwa\"#" \
  | sed -E "s#PICARD=.*#PICARD=\"java -jar /usr/gitc/picard.jar\"#" \
  | sed -E "s#CELL_RANGER=.*#CELL_RANGER=\"/usr/gitc/cellranger-6.0.1/bin/cellranger\"#" \
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
  >> ${TEST_NEXTFLOW_CONFIG}

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
CMD="nextflow -C ${TEST_NEXTFLOW_CONFIG} run ${LOCATION}/../../main.nf --run ${RUN}" # > ${RUN_OUT}"
echo $CMD
eval $CMD