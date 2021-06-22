#!/bin/bash
# Uploads cellranger files to ngs-stats
# Nextflow Inputs:
#   LAUNCHED_CELLRANGER, path ("launched_cellranger_dirs.txt") - list of directories to monitor for cellranger stats
#
#   example launched_cellranger_dirs.txt:
#     ```
#     /igo/staging/stats/RUN/cellranger/project/sample1 count web_summary.html metrics_summary.csv
#     /igo/staging/stats/RUN/cellranger/project/sample2 vdj metrics_summary.csv
#     ...
#     ```
# Run:
#   $ ls
#   launched_cellranger_dirs.txt    # File MUST be present
#   ./upload_cellranger.sh

# We create a copy of the original file
ORIGINAL_FILE=original_launched_cellranger_dirs.txt
cp launched_cellranger_dirs.txt ${ORIGINAL_FILE}

echo "Checking for directories to upload: $(cat ${ORIGINAL_FILE} | cut -d' ' -f1 | tr '\n' ' ')"

# As long as this file is populated with directories to check, continue
while [[ -z $(cat launched_cellranger_dirs.txt) ]]; do
  ts=$(date +'%m_%d_%Y')
  upload_file=to_upload_${ts}.txt

  # Save current state
  cp launched_cellranger_dirs.txt ${upload_file}
  rm launched_cellranger_dirs.txt

  while IFS= read -r line; do
    DIR=$(echo ${line} | cut -d' ' -f1)
    CR_TYPE=$(echo ${line} | cut -d' ' -f2)   # 'count'/'vdj'
    FILES=$(echo ${line} | cut -d' ' -f3-)

    # DIR SHOULD HAVE THIS NAMING - /igo/staging/stats/RUN/cellranger/project/sample
    SAMPLE=$(basename ${DIR})
    PROJECT_DIR=$(dirname ${DIR})
    PROJECT=$(basename ${PROJECT_DIR})
    RUN_DIR=$(dirname $(dirname ${PROJECT_DIR}))
    RUN=$(basename ${RUN_DIR})

    UPLOAD_DIR="${STATSDONEDIR}/../CELLRANGER/${RUN}/${PROJECT}/${SAMPLE}__${CR_TYPE}/outs"

    echo "Checking RUN=${RUN} PROJECT=${PROJECT} SAMPLE=${SAMPLE} for files (${FILES})"
    for f in ${FILES}; do
      completed_file=$(find ${DIR} -type f -name ${f})
      if [[ -z ${completed_file} || ! -f ${completed_file} ]]; then
        printf "\tSkipping Upload: No ${f}\n"
        MISSING=YES
      else
        printf "\tFound ${f}. Copying to ${UPLOAD_DIR}"
        cp ${f} ${UPLOAD_DIR}
      fi
    done

    if [[ ! -z ${MISSING} ]]; then
      printf "\tUploading CellRanger stats for RUN=${RUN} PROJECT=${PROJECT} SAMPLE=${SAMPLE}\n"
      JSON="{ 'samples': [ { 'sample': '${SAMPLE}', 'type': '${CR_TYPE}', 'project': '${PROJECT}', 'run': '${RUN}'}]}"
      JSON_STR=$(echo ${JSON} | sed "s/'/\"/g")

      CURL_CMD="curl -d \"${JSON_STR}\" -H 'Content-Type: application/json' -X POST 'http://delphi.mskcc.org:8080/ngs-stats/saveCellRangerSample'"
      printf "\t${CURL_CMD}\n"
      eval ${CURL_CMD}
    else
      # Add line back so it can be re-evaluated on next pass
      echo $line >> launched_cellranger_dirs.txt
    fi
  done < ${upload_file}

  # Sleep for 30 minutes and then check again
  sleep 1800
done

echo "DONE."
