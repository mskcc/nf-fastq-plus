#!/bin/bash

LOCATION=$(dirname "$0")
cd ${LOCATION}
TEST=GeneExpression
echo "Running ${TEST} Test"
OUTPUT=${TEST}_test.out
STATS_DIR=$(pwd) \
  CELLRANGER_ATAC="echo" \      # These would be the cellranger commands, we pass echo so we can spy on the params
  CELLRANGER="echo" \
  CELLRANGER_CNV="echo" \
  FASTQ_DIR=$(pwd) \
  RUN_PARAMS_FILE="sample_params.txt" \
  ../../../templates/cellranger.sh > ${OUTPUT}
EXPECTED_OUT="count --id=ESC_IGO_00001_1 --transcriptome=/igo/work/nabors/genomes/10X_Genomics/GEX/refdata-gex-GRCh38-2020-A --fastqs= --nopreflight --jobmode=lsf --mempercore=64 --disable-ui --maxjobs=200"
ACTUAL_OUT=$(cat ${OUTPUT})
if [[ ! -z $(echo ${ACTUAL_OUT} | grep "${EXPECTED_OUT}") ]]; then
  echo "Passed ${TEST}: ${EXPECTED_OUT}"
  rm ${OUTPUT}
  rm -rf ROSALIND_0339_AH2VTWBGXJ   # This is the FASTQ directory that we pointed the script to write to w/ FASTQ_DIR
else
  echo "Failed ${TEST}: ${ACTUAL_OUT}"
  exit 1
fi
