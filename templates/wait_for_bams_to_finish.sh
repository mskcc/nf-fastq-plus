#!/bin/bash

BAM_TRACKING_FILE=run_bams.txt
ORIGINAL_FILE=output_bams.txt
if [[ ! -f ${BAM_TRACKING_FILE} ]]; then
  echo "Did not find ${BAM_TRACKING_FILE}"
  exit 1
fi
# We create a copy of the original file
cp ${BAM_TRACKING_FILE} ${ORIGINAL_FILE}

if [[ -z ${CELLRANGER_WAIT_TIME} ]]; then
  DEFAULT_WAIT=1800
  echo "Using Default - CELLRANGER_WAIT_TIME=${DEFAULT_WAIT}"
  CELLRANGER_WAIT_TIME=${DEFAULT_WAIT} # Time to sleep between checking for cellranger files, e.g. "1800" is 30 min
else
  echo "CELLRANGER_WAIT_TIME=${CELLRANGER_WAIT_TIME}"
fi

echo "Checking for alignment stats for BAM to write: $(cat ${ORIGINAL_FILE} | tr '\n' ' ')"

# As long as this file is populated with directories to check, continue
while [[ ! -z $(cat ${BAM_TRACKING_FILE}) ]]; do
  # Delete & repopulate launched_cellranger_dirs.txt. Save remaining pending samples to a timestamped file (upload_file)
  ts=$(date +'%H_%M_%m_%d_%Y')
  echo "Checking at ${ts}"

  # Copy tracking file to file to iterate through then remove. Onlyl add pending BAMs back to tracking file
  upload_file=pending_${ts}.txt
  cp ${BAM_TRACKING_FILE} ${upload_file}
  rm ${BAM_TRACKING_FILE}

  for BAM in $(cat ${upload_file}); do
    ${SAMTOOLS} quickcheck ${BAM} # Error if invalid headers or no EOF block, otherewise exit w/ exit code 0
    if [[ 0 -eq $? ]]; then
      echo "Valid BAM has been written: ${BAM}"
    else
      echo "BAM PENDING BAM=${BAM}"
      echo "${BAM}" >> ${BAM_TRACKING_FILE}
    fi
  done

  # Check again here. If re-doing a RUN that already has stats, seems silly to wait ${CELLRANGER_WAIT_TIME} minutes
  if [[ ! -z $(cat ${BAM_TRACKING_FILE}) ]]; then
    echo "Still Pending BAMs..."
    sleep ${CELLRANGER_WAIT_TIME}
  fi
done

echo "DONE."
