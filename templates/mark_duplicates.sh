#!/bin/bash
# Performs an alignment on input @SAM_LIST
# Nextflow Inputs:
#   PICARD,     Picard Command
# 
#   PRJ_SMP,    Key used to group all SAM files
#   SAM_LIST,   Stringified Java List of SAM files 
# Nextflow Outputs:
#   MERGED_BAM, Output from Picard's MergeSamFiles
# Run:

#   TODO - Use Each?
INPUT_BAM=$(ls)

MD_TAG="${RUN_TAG}___MD"
METRICS="${MD_TAG}.txt"
MD_BAM="${MD_TAG}.bam"

echo "Running MarkDuplicates: ${MD_TAG}"
CMD="!{PICARD} MarkDuplicates CREATE_INDEX=true METRICS_FILE=${RUN_TAG}___MD.txt OUTPUT=${MD_BAM} INPUT=${INPUT_BAM}"
echo $CMD
touch $MD_BAM
