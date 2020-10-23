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
#   TODO

SAMS=${SAM_LIST//[,[\]]}
NUM_SAMS=$(echo $SAMS | tr ' ' '\n' | wc -l)
MERGED_BAM="${RUN_TAG}___MRG.bam"
echo "Merging ${NUM_SAMS} SAM(s) for RUN_TAG: ${MERGED_BAM}"

MERGE_CMD="!{PICARD} MergeSamFiles CREATE_INDEX=true O=${MERGED_BAM}"
for SAM in $SAMS; do
  MERGE_CMD="${MERGE_CMD} I=${SAM}"
done

echo $MERGE_CMD
touch $MERGED_BAM
