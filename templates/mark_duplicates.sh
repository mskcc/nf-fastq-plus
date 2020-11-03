#!/bin/bash
# Performs an alignment on input @SAM_LIST,  if MD="yes"
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Location to copy stats to
# 
#   PRJ_SMP,    Key used to group all SAM files
#   SAM_LIST,   Stringified Java List of SAM files 
#   MD,		yes/no of whether to run mark_duplicates
# Nextflow Outputs:
#   MERGED_BAM, Output from Picard's MergeSamFiles
# Run:

#   TODO - Use Each?
INPUT_BAM=$(ls)

METRICS_DIR=!{STATS_DIR}/${RUNNAME}
mkdir -p ${METRICS_DIR}
MD_TAG="${RUN_TAG}___MD"
METRICS_FILE="${METRICS_DIR}/${MD_TAG}.txt"
MD_BAM="${MD_TAG}.bam"

if [[ -z $(echo ${MD} | grep -i "yes") ]]; then
  NO_MD_BAM="${RUN_TAG}___NO_MD.bam"
  echo "Not running Mark Duplicates (MD: ${MD}). Creating symbolic link to input - ${NO_MD_BAM}"
  ln -s ${INPUT_BAM} ${NO_MD_BAM}
  exit 0
fi

echo "Running MarkDuplicates (MD: ${MD}): ${MD_TAG}. Writing to ${METRICS_DIR}"
CMD="!{PICARD} MarkDuplicates CREATE_INDEX=true METRICS_FILE=${METRICS_FILE} OUTPUT=${MD_BAM} INPUT=${INPUT_BAM}"
echo $CMD
touch $MD_BAM
touch $METRICS_FILE