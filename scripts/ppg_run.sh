#!/bin/bash

LOCATION=$(dirname "$0")

print_usage() {
  echo "./ppg_run.sh -d [DEMUX_DIR]"
  printf "\t./ppg_run.sh -d demux_dir\n"
}

while getopts 'd:' flag; do
  case "${flag}" in
    d) DEMUX_DIR="${OPTARG} " ;;     # Reference to create liftover file for, e.g. GRCh37
    *) print_usage
       exit 1 ;;
  esac
done

PROJECT_DIRS=$(find ${DEMUX_DIR} -maxdepth 1 -type d -name "Project*")
for d in ${PROJECT_DIRS}; do
  SAMPLE_DIRS=$(find ${d} -mindepth 1 -maxdepth 1 -type d)
  for sample_dir in ${SAMPLE_DIRS}; do
    SAMPLE=$(basename ${sample_dir})
    FASTQS=$(find ${sample_dir} -type f -name "*fastq.gz" | sed 's/^/ -f /g' | tr '\n' ' ')
    CMD="${LOCATION}/ppg_smp.sh -s ${SAMPLE} ${FASTQS}"
    echo ${CMD}
    JOB_NAME="PPG___${SAMPLE}" 
    bsub -J ${JOB_NAME} -o ${JOB_NAME}.out -n 10 -M 16 "${CMD}"
  done
done
