#!/bin/bash

LOCATION=$(dirname "$0")

print_usage() {
  echo "./ppg_run.sh -d [DEMUX_DIR]"
  printf "\t./ppg_run.sh -d demux_dir\n"
}

while getopts 'd:' flag; do
  case "${flag}" in
    f) DEMUX_DIR="${OPTARG} " ;;     # Reference to create liftover file for, e.g. GRCh37
    *) print_usage
       exit 1 ;;
  esac
done

if [[ -z ${DEMUX_DIR} || ! -d ${DEMUX_DIR} ]]; then
  echo "provide demultilexed directory"
  print_usage
  exit 1
fi

PROJECT_DIRS=$(find ${DEMUX_DIR} -maxdepth 1 -type d -name "Project*")
for d in ${PROJECT_DIRS}; do
  SAMPLE_DIRS=$(find ${d} -mindepth 1 -maxdepth 1 -type d)
  for sample_dir in ${SAMPLE_DIRS}; do
    SAMPLE=$(basename ${sample_dir})
    FASTQS=$(find ${sample_dir} -type f -name "*fastq.gz")
    CMD="${LOCATION}/ppg_smp.sh -s ${SAMPLE} ${FASTQS}"
    echo ${CMD}
done
