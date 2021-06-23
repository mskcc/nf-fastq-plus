#!/bin/bash
# Script to detect new seqeuncer runs ready to be demultiplexed, the full path of the script must be used
# Example: sh /home/igo/nf-fastq-plus/crontab/detect_copied_sequencers.sh

source ~/.bash_profile # load java, singularity, python, etc

NUM_MINS_OLD=60
EVENTS_API="http://dlviigoweb1:4500/api/nextflow/receive-nextflow-event"

LOCATION=$(dirname "$0")
WHOAMI=$(basename "$0")

NEXTFLOW_CONFIG=${LOCATION}/../nextflow.config

echo ""
echo "[$(date "+%Y%m%d") $(date +"%T")] Running ${LOCATION}/${WHOAMI}"
echo "Taking SEQUENCER_DIR & FASTQ_DIR from ${NEXTFLOW_CONFIG}"
eval $(cat ${NEXTFLOW_CONFIG} | grep SEQUENCER_DIR)	# e.g. eval SEQUENCER_DIR="/igo/sequencers"
eval $(cat ${NEXTFLOW_CONFIG} | grep FASTQ_DIR)		# e.g. eval FASTQ_DIR="/igo/stats/NF_TESTING/FASTQ"
WORK_DIR=$(dirname ${FASTQ_DIR})/working
echo "SEQUENCER_DIR=${SEQUENCER_DIR} FASTQ_DIR=${FASTQ_DIR} WORK_DIR=${WORK_DIR}"

RECENTLY_CREATED_RUN_DIRS=$(find ${SEQUENCER_DIR} -mindepth 2 -maxdepth 2 -type d -mmin -${NUM_MINS_OLD})
PEPE_DIR=$(find ${SEQUENCER_DIR}/pepe/output -mindepth 1 -maxdepth 1 -type d -mmin -${NUM_MINS_OLD})

# We filter the previous find command by directories w/ FILES written within the past day.
# For some reason, it looks like sequencer run folders are "touched" by res_igo_seq 
NEW_RUNS=()
for DIR in "${RECENTLY_CREATED_RUN_DIRS} ${PEPE_DIR}"; do
  RECENTLY_SEQUENCED_FILES=$(find $DIR -maxdepth 1 -type f -mmin -${NUM_MINS_OLD})
  if [[ ! -z "${RECENTLY_SEQUENCED_FILES}" ]]; then
    NEW_RUNS+=(${DIR})
  fi
done

echo "${#NEW_RUNS[@]} runs have been updaed in the past ${NUM_MINS_OLD} minute(s): ${NEW_RUNS[*]}"
if [[ ${#NEW_RUNS[@]} -eq 0 ]]; then
  echo "Exiting."
  exit 0
fi
echo "Checking whether each run has been copied over completely..."

for RUN in ${NEW_RUNS[@]}; do
  printf "\tVERIFYING: $RUN\n"
  # Run the nextflow process script that determines if the run is good to be demultiplexed. On error, run is skipped
  RUN_LOG_DIR=/home/igo/nf-fastq-plus/crontab/runs_detected
  mkdir -p ${RUN_LOG_DIR}
  RUN_LOG=${RUN_LOG_DIR}/$(basename ${RUN}).log
  touch $RUN_LOG
  DEMUX_ALL=false FASTQ_DIR=${FASTQ_DIR} SEQUENCER_DIR=${SEQUENCER_DIR} RUN=${RUN} "${LOCATION}/../templates/detect_runs.sh" > ${RUN_LOG}
  if [ $? -eq 0 ]; then
    RUNNAME=$(basename ${RUN})
    RUN_DIR=${WORK_DIR}/${RUNNAME}
    mkdir -p ${RUN_DIR}
    cd ${RUN_DIR}
    printf "\tDEMULTIPLEXING: RUN=${RUN} WORK_DIR=$(pwd)\n"
    nohup nextflow ${LOCATION}/../main.nf --run ${RUNNAME} -with-weblog "${EVENTS_API}" -bg >> "nf_${RUNNAME}.log"
    cd -
  else
    printf "\tNOT DEMULTIPLEXING: ${RUN}\n"
  fi
  echo ""
done


