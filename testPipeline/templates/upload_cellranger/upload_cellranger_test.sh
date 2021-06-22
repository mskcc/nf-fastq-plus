#!/bin/bash
# Tests that the cellranger upload waits for files to be written (mocks cellranger writing) and copies to expected
# directory ngs-stats would be looking for, ${STATS_DIR}/CELLRANGER

INPUT_NEXTFLOW_FILE=launched_cellranger_dirs.txt
WS_F="web_summary.html"
MS_F="metrics_summary.csv"

# Take from sample_params.txt in this directory
RUN=ROSALIND_0001_FLOWCELL
PROJECT=P10001
S1=sample1    # Samples can be anything
S2=sample2

# Setup directories cellranger WOULD be writing to
RUN_DIR=$(pwd)/${RUN}
PROJECT_DIR=${RUN_DIR}/cellranger/${PROJECT}
COUNT_DIR=${PROJECT_DIR}/${S1}
VDJ_DIR=${PROJECT_DIR}/${S2}

# Setup Output directories
STATS_DIR=$(pwd)/stats
STATSDONEDIR=${STATS_DIR}/DONE
CELLRANGER=${STATS_DIR}/CELLRANGER
mkdir -p ${COUNT_DIR} && mkdir -p ${VDJ_DIR}
mkdir -p ${STATSDONEDIR} && mkdir -p ${CELLRANGER}

# Populate sample input file that would be fed in by nextflow
echo "${COUNT_DIR} count ${WS_F} ${MS_F}" >> ${INPUT_NEXTFLOW_FILE}
echo "${VDJ_DIR} vdj ${MS_F}" >> ${INPUT_NEXTFLOW_FILE}

# Verify setup is correct and files aren't already written
if [[ 2 -eq $(find ${CELLRANGER} -type f -name ${MS_F} | wc -l) ]]; then
  echo "Invalid setup - There shouldn't be any ${MS_F} files in ${CELLRANGER}"
  exit 1
fi
if [[ 1 -eq $(find ${CELLRANGER} -type f -name ${WS_F} | wc -l) ]]; then
  echo "Invalid setup - There shouldn't be any ${WS_F} files in ${CELLRANGER}"
  exit 1
fi

# Write files upload task will be looking for from the cellragner task
{ sleep 1; touch ${COUNT_DIR}/${WS_F}; touch ${COUNT_DIR}/${MS_F}; } &
{ sleep 1; touch ${VDJ_DIR}/${MS_F}; } &

# Run command
STATSDONEDIR=${STATSDONEDIR} CELLRANGER_WAIT_TIME=2 ../../../templates/upload_cellranger.sh

# Verify files were written and copied over to the directory ngs-stats will expect to find them
OUTPUT_MS_FILES=$(find ${CELLRANGER} -type f -name ${MS_F})
OUTPUT_WS_FILES=$(find ${CELLRANGER} -type f -name ${WS_F})
if [[ 2 -ne $(echo ${OUTPUT_MS_FILES} | tr ' ' '\n' | wc -l) ]]; then
  echo "ERROR - There should be 2 ${MS_F} files in ${CELLRANGER}"
  find ${CELLRANGER} -type f -name ${MS_F}
  exit 1
fi
if [[ 1 -ne $(echo ${OUTPUT_WS_FILES} | tr ' ' '\n' | wc -l) ]]; then
  echo "ERROR - There should be 1 ${WS_F} file in ${CELLRANGER}"
  find ${CELLRANGER} -type f -name ${WS_F}
  exit 1
fi

# Cleanup
rm -rf ${STATS_DIR}
rm -rf ${RUN_DIR}
rm original_launched_cellranger_dirs.txt
rm to_upload_*.txt

echo "SUCCESS"
echo "OUTPUT_MS_FILES: ${OUTPUT_MS_FILES}"
echo "OUTPUT_WS_FILES: ${OUTPUT_WS_FILES}"
