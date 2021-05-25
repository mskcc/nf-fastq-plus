#!/bin/bash

OUTPUT_FILE=output.txt

LOCATION=$(dirname "$0")
cd ${LOCATION}

FASTQ_DIR=$(pwd)
FASTQ_RUN_DIR=${FASTQ_DIR}/RUN
FASTQ_SAMPLE_DIR=${FASTQ_RUN_DIR}/Project_10001/Sample_ESC_IGO_00001_1

#########################################
# Runs the cellranger command w/ test inputs
# Globals:
#   OUTPUT_FILE - where to write the command output to (used for testing later)
# Arguments:
#   type - The recipe type that is being tested samplesheet suffix. This is also the suffix of the sample_params*.txt
#########################################
run_cellranger() {
  type=$1
  rpf="sample_params_${type}.txt"
  echo "Running ${type} Test"
  # These would be the cellranger commands, we pass echo so we can spy on the params
  CELLRANGER_ATAC="echo" \
    CELL_RANGER="echo" \
    CELL_RANGER_CNV="echo" \
    CELL_RANGER_ATAC="echo" \
    FASTQ_DIR=$(pwd) \
    CMD_FILE=/dev/null \
    RUN_PARAMS_FILE="${rpf}" \
    STATS_DIR=$(pwd) ../../../templates/cellranger.sh > ${OUTPUT_FILE}
}

# Need to setup a mock FASTQ directory
mkdir -p ${FASTQ_SAMPLE_DIR}
touch ${FASTQ_SAMPLE_DIR}/Sample_ESC_IGO_00001_1_R1.fastq.gz
touch ${FASTQ_SAMPLE_DIR}/Sample_ESC_IGO_00001_1_R2.fastq.gz

run_cellranger GeneExpression
EXPECTED_OUT="count --id=ESC_IGO_00001_1 --transcriptome=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A --fastqs=/Users/streidd/work/nf-fastq-plus/testPipeline/templates/cellranger/RUN/Project_10001/Sample_ESC_IGO_00001_1 --nopreflight --jobmode=lsf --mempercore=64 --disable-ui --maxjobs=200"
ACTUAL_OUT=$(cat ${OUTPUT_FILE})
if [[ ! -z $(echo ${ACTUAL_OUT} | grep "${EXPECTED_OUT}") ]]; then
  echo "Passed ${TEST}: ${EXPECTED_OUT}"
  rm ${OUTPUT_FILE}
  rm -rf ROSALIND_0339_AH2VTWBGXJ   # This is the FASTQ directory that we pointed the script to write to w/ FASTQ_DIR
else
  echo "Failed ${TEST}: ${ACTUAL_OUT}"
  exit 1
fi

run_cellranger vdj
EXPECTED_OUT="vdj --id=ESC_IGO_00001_1 --reference=/igo/work/nabors/genomes/10X_Genomics/VDJ/refdata-cellranger-vdj-GRCh38-alts-ensembl-2.0.0 --fastqs=/Users/streidd/work/nf-fastq-plus/testPipeline/templates/cellranger/RUN/Project_10001/Sample_ESC_IGO_00001_1 --sample=ESC_IGO_00001_1 --nopreflight --jobmode=lsf --mempercore=64 --disable-ui --maxjobs=200"
ACTUAL_OUT=$(cat ${OUTPUT_FILE})
if [[ ! -z $(echo ${ACTUAL_OUT} | grep "${EXPECTED_OUT}") ]]; then
  echo "Passed ${TEST}: ${EXPECTED_OUT}"
  rm ${OUTPUT_FILE}
  rm -rf ROSALIND_0339_AH2VTWBGXJ   # This is the FASTQ directory that we pointed the script to write to w/ FASTQ_DIR
else
  echo "Failed ${TEST}: ${ACTUAL_OUT}"
  exit 1
fi

run_cellranger atac
EXPECTED_OUT="count --id=ESC_IGO_00001_1 --fastqs=/Users/streidd/work/nf-fastq-plus/testPipeline/templates/cellranger/RUN/Project_10001/Sample_ESC_IGO_00001_1 --reference=/igo/work/nabors/genomes/10X_Genomics/ATAC/refdata-cellranger-atac-GRCh38-1.0.1 --nopreflight --jobmode=lsf --mempercore=64 --disable-ui --maxjobs=200"
ACTUAL_OUT=$(cat ${OUTPUT_FILE})
if [[ ! -z $(echo ${ACTUAL_OUT} | grep "${EXPECTED_OUT}") ]]; then
  echo "Passed ${TEST}: ${EXPECTED_OUT}"
  rm ${OUTPUT_FILE}
  rm -rf ROSALIND_0339_AH2VTWBGXJ   # This is the FASTQ directory that we pointed the script to write to w/ FASTQ_DIR
else
  echo "Failed ${TEST}: ${ACTUAL_OUT}"
  exit 1
fi

echo "All Tests Pass - Removing ${FASTQ_RUN_DIR}"
rm -rf ${FASTQ_RUN_DIR}
