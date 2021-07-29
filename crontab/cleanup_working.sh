#!/bin/bash
# Script to detect new seqeuncer runs ready to be demultiplexed, the full path of the script must be used
# Example: sh /home/igo/nf-fastq-plus/crontab/detect_copied_sequencers.sh

source ~/.bash_profile # load java, singularity, python, etc

NUM_DAYS_OLD=14

LOCATION=$(dirname "$0")
WHOAMI=$(basename "$0")

NEXTFLOW_CONFIG=${LOCATION}/../nextflow.config

echo ""
echo "[$(date "+%Y%m%d") $(date +"%T")] Running ${LOCATION}/${WHOAMI}"
eval $(cat ${NEXTFLOW_CONFIG} | grep FASTQ_DIR)		  # e.g. eval FASTQ_DIR="/igo/stats/NF_TESTING/FASTQ"
WORK_DIR=$(dirname ${FASTQ_DIR})/working
echo "WORK_DIR=${WORK_DIR}"

if [[ ! -d ${WORK_DIR} ]]; then
  echo "Invalid WORK_DIR"
  exit 1
fi

OLD_DIRS=$(find ${WORK_DIR} -mindepth 1 -maxdepth 1 -ctime +${NUM_DAYS_OLD})
NUM_OLD_DIRS=$(echo ${OLD_DIRS} | tr ' ' '\n' | wc -l)

echo "Removing ${NUM_OLD_DIRS} Directories: ${OLD_DIRS}"

for dir in ${OLD_DIRS}; do
  if [[ ! -d ${dir}/.nextflow ]]; then
    echo "Skipping ${dir} b/c it doesn't look like a nextflow directory"
    continue
  fi
  echo "Removing ${dir}"
  rm -rf ${dir}
done
