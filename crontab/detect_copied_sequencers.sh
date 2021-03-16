NUM_DAYS_OLD=1 # Age of recent sequenced run to run through pipeline

# DIR location should come from nextflow.config
SEQ_DIR=/igo/sequencers/
# FASTQ_DIR=/igo/work/FASTQ
FASTQ_DIR=/igo/work/streidd/PIPELINE_TESTS/FASTQ
WORK_DIR=/igo/work/streidd/PIPELINE_REPEATS

RECENTLY_CREATED_RUN_DIRS=$(find ${SEQ_DIR} -mindepth 2 -maxdepth 2 -type d -mtime -${NUM_DAYS_OLD})

# We filter the previous find command by directories w/ FILES written within the past day.
# For some reason, it looks like sequencer run folders are "touched" by res_igo_seq 
NEW_RUNS=()
for DIR in ${RECENTLY_CREATED_RUN_DIRS}; do
  RECENTLY_SEQUENCED_FILES=$(find $DIR -maxdepth 1 -type f -mtime -${NUM_DAYS_OLD})
  if [[ ! -z "${RECENTLY_SEQUENCED_FILES}" ]]; then
    NEW_RUNS+=(${DIR})
  fi
done

LOCATION=$(dirname "$0")
WHOAMI=$(basename "$0")

echo "Running ${LOCATION}/${WHOAMI}"

for RUN in ${NEW_RUNS[@]}; do
  echo "VERIFYING: $RUN"
  # Run the nextflow process script that determines if the run is good to be demultiplexed. On error, run is skipped
  DEMUX_ALL=false FASTQ_DIR=${FASTQ_DIR} SEQUENCER_DIR=${SEQ_DIR} RUN=${RUN} "${LOCATION}/../templates/detect_runs.sh"
  if [ $? -eq 0 ]; then
    echo "DEMULTIPLEXING: ${RUN}"
    RUNNAME=$(basename ${RUN})
    RUN_DIR=${WORK_DIR}/${RUNNAME}
    mkdir -p ${RUN_DIR}
    cd ${RUN_DIR}
    nohup nextflow ${LOCATION}/../main.nf --run ${RUNNAME} -bg
    pwd
    cd -
  else
    echo "NOT DEMULTIPLEXING: ${RUN}"
  fi
done

