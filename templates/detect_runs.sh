#!/bin/bash
#
# Script that reads done files from sequencing directories and outputs paths
# to run directories that should be submitted to the pipeline 
# 
# Arguments:
#   SEQUENCER_DIR: Parent directory of done files
#   RUN_AGE: Maxmimum age of recent write to done folder
#   RUNS_TO_DEMUX_FILE: Output file to write runs recently completed
# Outputs (STD OUT):
#   Absolute paths to run dierectorIES

DONE_FILE="Run_Done.txt"
touch ${RUNS_TO_DEMUX_FILE}

sequencer_files=( ${SEQUENCER_DIR}/johnsawyers/*/RTAComplete.txt
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
  find $(ls $file) -mmin -${RUN_AGE} >> ${DONE_FILE}
done

NUM_RUNS=$(cat ${DONE_FILE} | wc -l)

echo "Detected ${NUM_RUNS} new runs"

foo()

if [[ $NUM_RUNS -eq 0 ]]; then
  echo "Exiting. No new runs" 
  exit
fi

echo "Outputting new runs to ${PIPELINE_OUT}"

for x in $(cat ${DONE_FILE}) ; do
  #Deletes shortest match of $substring '/*Complet*' from back of $x
  RUNPATH=$(echo ${x%/*Complet*})
  IFS='/'
  array=($RUNPATH)
  MACHINE="${array[3]}"
  RUN="${array[4]}"
  IFS=','

  RUNNAME=$(echo $RUN | awk '{pos=match($0,"_"); print (substr($0,pos+1,length($0)))}')
  if [ -z "$RUNNAME" ] ; then
    echo "WARNING: Could not parse out run from RUNNAME: $RUNNAME"
  fi

  echo "Processing RUN=$RUN RUNNAME=$RUNNAME RUNPATH=$RUNPATH DEMUX_TYPE=$DEMUX_TYPE"

  # If the run has already been demuxed, then it will be in the FASTQ directory.
  # TODO - While we should have this check, this won't work since we append suffixes to runs that need to be re-demuxed
  demuxed_run="" # $(ls /ifs/input/GCL/hiseq/FASTQ/ | grep "$RUNNAME")

  # echo $RUNNAME | mail -s "IGO Cluster New Run Sent for Demuxing" mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org

  echo $RUNPATH >> ${RUNS_TO_DEMUX_FILE}
done
