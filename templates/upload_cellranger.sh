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

if [[ -z ${CELLRANGER_WAIT_TIME} ]]; then
  DEFAULT_WAIT=1800
  echo "Using Default - CELLRANGER_WAIT_TIME=${DEFAULT_WAIT}"
  CELLRANGER_WAIT_TIME=${DEFAULT_WAIT} # Time to sleep between checking for cellranger files, e.g. "1800" is 30 min
else
  echo "CELLRANGER_WAIT_TIME=${CELLRANGER_WAIT_TIME}"
fi

echo "Checking for directories to upload: $(cat ${ORIGINAL_FILE} | cut -d' ' -f1 | tr '\n' ' ')"

# As long as this file is populated with directories to check, continue
while [[ ! -z $(cat launched_cellranger_dirs.txt) ]]; do
  # Delete & repopulate launched_cellranger_dirs.txt. Save remaining pending samples to a timestamped file (upload_file)
  ts=$(date +'%m_%d_%Y')
  upload_file=to_upload_${ts}.txt
  cp launched_cellranger_dirs.txt ${upload_file}
  rm launched_cellranger_dirs.txt

  while IFS= read -r line; do
    MISSING=
    DIR=$(echo ${line} | cut -d' ' -f1)
    CR_TYPE=$(echo ${line} | cut -d' ' -f2)   # 'count'/'vdj'
    FILES=$(echo ${line} | cut -d' ' -f3-)

    # DIR SHOULD HAVE THIS NAMING - /igo/staging/stats/RUN/cellranger/project/sample
    SAMPLE=$(basename ${DIR})                     # /igo/staging/stats/RUN/cellranger/project/sample  -> sample
    PROJECT_DIR=$(dirname ${DIR})
    PROJECT=$(basename ${PROJECT_DIR})            # /igo/staging/stats/RUN/cellranger/project         -> project
    RUN_DIR=$(dirname $(dirname ${PROJECT_DIR}))
    RUN=$(basename ${RUN_DIR})                    # /igo/staging/stats/RUN                            -> RUN
    # Remove any trailing P's, run-qc makes request like, ".../ngs-stats/getCellRangerSample?project=12186&type=count"
    CLEANED_PROJECT=$(echo ${PROJECT} | sed "s/^P//g")

    echo "Checking RUN=${RUN} CLEANED_PROJECT=${CLEANED_PROJECT} SAMPLE=${SAMPLE} for files (${FILES})"
    for f in ${FILES}; do
      completed_file=$(find ${DIR} -type f -name ${f})
      if [[ -z ${completed_file} || ! -f ${completed_file} ]]; then
        printf "\tSkipping Upload: No ${f}\n"
        MISSING=YES
      else
        # EXPECTED: ...CELLRANGER/DIANA_0380_BHY3FYDMXX/Project_12133/Sample_1xx1xxP_IGO_12133_1__count/outs/
        UPLOAD_DIR="${STATSDONEDIR}/../CELLRANGER/${RUN}/${CLEANED_PROJECT}/Sample_${SAMPLE}__${CR_TYPE}/outs"
        mkdir -p ${UPLOAD_DIR}
        printf "\tFound ${f}. Copying to ${UPLOAD_DIR}\n"
        cp ${completed_file} ${UPLOAD_DIR}
      fi
    done

    if [[ -z ${MISSING} ]]; then
      printf "\tUploading CellRanger stats for RUN=${RUN} CLEANED_PROJECT=${CLEANED_PROJECT} SAMPLE=${SAMPLE}\n"
      JSON="{ 'samples': [ { 'sample': '${SAMPLE}', 'type': '${CR_TYPE}', 'project': '${CLEANED_PROJECT}', 'run': '${RUN}'}]}"
      JSON_STR=$(echo ${JSON} | sed "s/'/\"/g") # replace all single-quotes w/ double-quotes for valid json

      CURL_CMD="curl -d '${JSON_STR}' -H 'Content-Type: application/json' -X POST 'http://delphi.mskcc.org:8080/ngs-stats/saveCellRangerSample'"
      printf "\t${CURL_CMD}\n"
      eval ${CURL_CMD}
    else
      # Add line back so it can be re-evaluated on next pass
      echo $line >> launched_cellranger_dirs.txt
    fi
  done < ${upload_file}

  sleep ${CELLRANGER_WAIT_TIME}
done

printf "\nDONE.\n"
