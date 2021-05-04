#!/bin/bash

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

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

RECIPE=$(parse_param ${RUN_PARAMS_FILE} RECIPE)          # Must include a WGS genome to run CollectWgsMetrics
SAMPLE_TAG=$(parse_param ${RUN_PARAMS_FILE} SAMPLE_TAG)

# Find All Sample Directories, e.g. /igo/work/FASTQ/SCOTT_0339_AH2VTWBGXJ_10X/Project_11926/Sample_ESC_IGO_11926_1
SAMPLE_FASTQ_DIRS_ACROSS_RUNS=$(find ${FASTQ_DIR} -mindepth 3 -maxdepth 3 -type d -name "Sample_${SAMPLE_TAG}")
CELLRANGER_FASTQ_INPUT=$(echo ${SAMPLE_FASTQ_DIRS_ACROSS_RUNS} | tr ' ' ',')

is_10X=$(echo $RECIPE | grep "10X_Genomics_")
if [[ -z ${is_10X} ]]; then
  echo "Non-10X Recipe: ${RECIPE}. Skipping"
else
  echo "Detected 10X Recipe: ${RECIPE}"
  if [[ ! -z $(echo ${RECIPE} | grep "GeneExpression") ]]; then
    # 10X_Genomics_NextGEM-GeneExpression
    # 10X_Genomics_NextGem_GeneExpression-5
    # 10X_Genomics_NextGEM_GeneExpression-5
    # 10X_Genomics_GeneExpression
    # 10X_Genomics_GeneExpression-3
    # 10X_Genomics_GeneExpression-5

    echo "Processing GeneExpression"
    ${CELLRANGER} count \
      --id=${SAMPLE_TAG} \
      --transcriptome=${CELLRANGER_TRANSCRIPTOME} \
      --fastqs=${CELLRANGER_FASTQ_INPUT} \
      --nopreflight \
      --jobmode=lsf \
      --mempercore=64 \
      --disable-ui \
      --maxjobs=200
  elif [[ ! -z $(echo ${RECIPE} | grep "VDJ") ]]; then
    # 10X_Genomics_NextGem_VDJ
    # 10X_Genomics_NextGEM_VDJ
    # 10X_Genomics_NextGEM-VDJ
    # 10X_Genomics_VDJ
    # 10X_Genomics-VDJ

    # TODO
    echo "Processing VDJ"
  elif [[ ! -z $(echo ${RECIPE} | grep "10X_Genomics_Visium") ]]; then
    # 10X_Genomics_Visium

    # TODO
    echo "Processing Visium"
  elif [[ ! -z $(echo ${RECIPE} | grep "10X_Genomics_ATAC") ]]; then
    # 10X_Genomics_ATAC

    # TODO
    echo "Processing ATAC"
  else
    # 10X_Genomics-Expression+VDJ
    # 10X_Genomics-FeatureBarcoding
    # 10X_Genomics_NextGEM-FB
    # 10X_Genomics_NextGEM_FeatureBarcoding

    # TODO
    echo "Processing Other"
  fi
fi
