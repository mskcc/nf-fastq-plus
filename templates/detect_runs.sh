#!/bin/bash
# 
# Script that finds the RUN_TO_DEMUX path for a given RUNNAME
# Arguments:
#   SEQUENCER_DIR, config: Parent directory of done files
#   FASTQ_DIR, config: Directory to find runs w/ FASTQ files
#   PIPELINE_OUT, config (Optional):  Output directory where outputs will be written in nextflow
#
#   RUN, param: Name or path to a sequencing run to proceed down the pipeline
#   DEMUX_ALL, param: Whether to force the demux, whether or not, it exists in FASTQ_DIR
# Outputs (STD OUT):
#   RUNNAME, env: value of what the runname (e.g. SCOTT_0277_AHKFKFBGXH)
#   RUNPATH, env: value of the absolute path to the run to be demultiplexed (e.g. /PATH/TO/210122_SCOTT_0277_AHKFKFBGXH)
# Run: 
#   DEMUX_ALL=true FASTQ_DIR=/igo/work/FASTQ SEQUENCER_DIR="/igo/sequencers" RUN_AGE=60 ./detect_runs.sh

echo "Received RUN=${RUN} DEMUX_ALL=${DEMUX_ALL}"

# ENV variables passed on in NEXTFLOW
RUNNAME="!{UNASSIGNED_PARAMETER}"
RUNPATH="!{UNASSIGNED_PARAMETER}"

echo "Outputting new runs to ${PIPELINE_OUT} and checking ${FASTQ_DIR} for existing runs"
# Assigns RUNPATH/RUN based on input run being the dir name or path to dir of the run
if [ -d "${RUN}" ]; then
  RUNDIR=$(basename ${RUN})
  RUNPATH=${RUN}
else
  RUNDIR=${RUN}
  # STRUCTURE: /{SEQUENCER_DIR}/{MACHINE}/{RUNNAME}
  RUNPATH=$(find !{SEQUENCER_DIR} -mindepth 2 -maxdepth 2 -type d -name "${RUNDIR}")
  if [[ -z "${RUNPATH}" ]]; then
    echo "Failed to find ${RUNDIR} in !{SEQUENCER_DIR}"
    exit 1
  fi
fi

# Remove prepended date - e.g. 210119_MICHELLE_0319_AH22J7DRXY -> MICHELLE_0319_AH22J7DRXY
RUNNAME=$(echo $RUNDIR | grep -oE "[A-Z]+.*") 
if [[ -z "${RUNNAME}" ]]; then
  echo "Unable to parse RUNNAME from ${RUNDIR}"
  exit 1
fi

NUM_RUNS=$(echo $RUNPATH | tr ' ' '\n' | wc -l)
if [[ "$NUM_RUNS" -ne 1 ]]; then
  echo "Not able to find one run folder for ${RUNNAME} in !{SEQUENCER_DIR}"
  exit 1
fi

MACHINE=$(basename $(dirname $RUNPATH)) # /igo/sequencers/jax/210119_JAX_0502_BHK72NBBXY/ -> "jax"
# File written when sequencing is complete
DONE_FILE="RTAComplete.txt" # johnsawyers kim momo toms vic ayyan
case $MACHINE in
  diana)
    DONE_FILE="CopyComplete.txt";; 
  michelle)
    DONE_FILE="CopyComplete.txt";;
  jax)
    DONE_FILE="SequencingComplete.txt";;
  pitt)
    DONE_FILE="SequencingComplete.txt";;
  scott)
    DONE_FILE="RunCompletionStatus.xml";;
  *)
    DONE_FILE="RTAComplete.txt";;
esac

echo "MACHINE=${MACHINE} RUN=${RUN} RUNNAME=${RUNNAME} DONE_FILE=${DONE_FILE} RUNPATH=${RUNPATH}"

DONE_FILE_PATH=${RUNPATH}/${DONE_FILE}
if test -f "${DONE_FILE_PATH}"; then
  echo "Sequencing Complete (${RUNNAME}): ${DONE_FILE_PATH}"
else
  echo "Sequencing NOT Complete: ${RUNNAME}"
  exit 1
fi

# If the run has already been demuxed, then it will be in the FASTQ directory.
demuxed_run=$( ls ${FASTQ_DIR} | grep -e "${RUNNAME}$" )
# TODO - uncomment
# echo $RUNNAME | mail -s "IGO Cluster New Run Sent for Demuxing" mcmanamd@mskcc.org naborsd@mskcc.org streidd@mskcc.org
if [[ "${demuxed_run}" == "" || "${DEMUX_ALL}" == "true" ]]; then
  echo "Run to Demux (Continue): RUN=$RUN RUNNAME=$RUNNAME RUNPATH=$RUNPATH"
else
  echo "Has Been Demuxed (Skip): RUN=$RUN RUNNAME=${RUNNAME} FASTQ_PATH=${FASTQ_DIR}/${demuxed_run}"
  exit 1
fi
