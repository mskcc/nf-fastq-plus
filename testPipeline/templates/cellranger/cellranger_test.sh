#!/bin/bash

LOCATION=$(dirname "$0")
cd ${LOCATION}

TEST=GeneExpression
echo "Running ${TEST} Test"
OUTPUT=${TEST}_test.out
CELLRANGER_TRANSCRIPTOME=refdata-gex-GRCh38-2020-A \
  FASTQ_DIR=$(pwd) \
  RUN_PARAMS_FILE="sample_params.txt" \
  CELLRANGER="echo /igo/work/bin/cellranger-6.0.0/cellranger" \
  ../../../templates/cellranger.sh > ${OUTPUT}
EXPECTED_OUT="/igo/work/bin/cellranger-6.0.0/cellranger count --id=ESC_IGO_00001_1 --transcriptome=refdata-gex-GRCh38-2020-A --fastqs= --nopreflight --jobmode=lsf --mempercore=64 --disable-ui --maxjobs=200"
ACTUAL_OUT=$(cat ${OUTPUT})
if [[ ! -z $(echo ${ACTUAL_OUT} | grep "${EXPECTED_OUT}") ]]; then
  echo "Passed ${TEST}: ${EXPECTED_OUT}"
  rm ${OUTPUT}
else
  echo "Failed ${TEST}: ${ACTUAL_OUT}"
  exit 1
fi
