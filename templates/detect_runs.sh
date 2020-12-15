#!/bin/bash
#
# Script that reads done files from sequencing directories and outputs paths
# to run directories that should be submitted to the pipeline. 
# Arguments:
#   DEMUX_ALL, param: Whether to force the demux, whether or not, it exists in FASTQ_DIR
#   RUNS_TO_DEMUX_FILE, config: Output file to write runs recently completed
#   SEQUENCER_DIR, config: Parent directory of done files
#   RUN_AGE, config: Maxmimum age of recent write to done folder
#   FASTQ_DIR, config: Directory to find runs w/ FASTQ files
#   PIPELINE_OUT, config (Optional):  Output directory where outputs will be written in nextflow
# Outputs (STD OUT):
#   Absolute paths to run directories
# Run: 
#   DEMUX_ALL=true FASTQ_DIR=/igo/work/FASTQ SEQUENCER_DIR="/igo/sequencers" RUN_AGE=60 RUNS_TO_DEMUX_FILE="Run_to_Demux.txt" ./detect_runs.sh

DONE_FILE="Run_Done.txt"
touch ${RUNS_TO_DEMUX_FILE}

DEMUX_ALL=$(("${DEMUX_ALL}" == "true"))
if [[ ${DEMUX_ALL} ]]; then
  echo "FORCE DEMUX: Processing all detected runs in past ${RUN_AGE} minutes."
else
  echo "Searching for new runs completed in past ${RUN_AGE} minutes"
fi

sequencer_files=( 
  ${SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
  ${SEQUENCER_DIR}/kim/*/RTAComplete.txt
  ${SEQUENCER_DIR}/momo/*/RTAComplete.txt
  ${SEQUENCER_DIR}/toms/*/RTAComplete.txt
  ${SEQUENCER_DIR}/vic/*/RTAComplete.txt
  ${SEQUENCER_DIR}/diana/*/CopyComplete.txt
  ${SEQUENCER_DIR}/michelle/*/CopyComplete.txt
  ${SEQUENCER_DIR}/jax/*/SequencingComplete.txt
  ${SEQUENCER_DIR}/pitt/*/SequencingComplete.txt
  ${SEQUENCER_DIR}/scott/*/RunCompletionStatus.xml
  ${SEQUENCER_DIR}/ayyan/*/RTAComplete.txt
)
for file in ${sequencer_files[@]}; do
  SEQ_DONE_FILES=$(find ${file} -mmin -${RUN_AGE})
  if [[ ! -z $SEQ_DONE_FILES ]]; then
    echo $SEQ_DONE_FILES >> ${DONE_FILE}
  fi
done

NUM_RUNS=$(cat ${DONE_FILE} | wc -l)

echo "Detected ${NUM_RUNS} new runs: $(cat ${DONE_FILE})"

if [[ $NUM_RUNS -eq 0 ]]; then
  echo "Exiting. No new runs" 
  exit 0
fi

echo "Outputting new runs to ${PIPELINE_OUT} and checking ${FASTQ_DIR} for existing runs"

for x in $(cat ${DONE_FILE}) ; do
  #Deletes shortest match of $substring '/*Complet*' from back of $x
  RUNPATH=$(echo ${x%/*Complet*})
  IFS='/'
  array=($RUNPATH)
  MACHINE="${array[3]}"
  RUN="${array[4]}"
  IFS=','

  echo $RUN
  RUNNAME=$(echo $RUN | awk '{pos=match($0,"_"); print (substr($0,pos+1,length($0)))}')
  if [ -z "$RUNNAME" ] ; then
    echo "ERROR: Could not parse out run from RUNNAME: $RUNNAME"
    continue
  fi
  
  # If the run has already been demuxed, then it will be in the FASTQ directory.
  demuxed_run=$( ls ${FASTQ_DIR} | grep -e "${RUNNAME}$" )
  # echo $RUNNAME | mail -s "IGO Cluster New Run Sent for Demuxing" mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org
  if [[ "${demuxed_run}" == "" || ${DEMUX_ALL} ]]; then
    echo "Run to Demux (Continue): RUN=$RUN RUNNAME=$RUNNAME RUNPATH=$RUNPATH DEMUX_TYPE=$DEMUX_TYPE"
    echo $RUNPATH >> ${RUNS_TO_DEMUX_FILE}
  else
    echo "Has Been Demuxed (Skip): RUN=$RUN RUNNAME=${RUNNAME} FASTQ_PATH=${FASTQ_DIR}/${demuxed_run}"
  fi
done
