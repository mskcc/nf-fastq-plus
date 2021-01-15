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

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard MergeSamFiles ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD}
  eval ${INPUT_CMD}
}

#########################################
# Reads input file and outputs param value
# Globals:
#   FILE - file of format "P1=V1 P2=V2 ..."
#   PARAM_NAME - name of parameter
# Arguments:
#   Lane - Sequencer Lane, e.g. L001
#   FASTQ* - absolute path to FASTQ
#########################################
parse_param() {
  FILE=$1
  PARAM_NAME=$2

  cat ${FILE}  | tr ' ' '\n' | grep -e "^${PARAM_NAME}=" | cut -d '=' -f2
}

RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)

SAMS=$(ls *.sam)
NUM_SAMS=$(echo $SAMS | tr ' ' '\n' | wc -l)
MERGED_BAM="${RUN_TAG}___MRG.bam"
echo "Merging ${NUM_SAMS} SAM(s): ${MERGED_BAM}"

MERGE_CMD="!{PICARD} MergeSamFiles CREATE_INDEX=true O=${MERGED_BAM}"
for SAM in $SAMS; do
  MERGE_CMD="${MERGE_CMD} I=${SAM}"
done

run_cmd $MERGE_CMD
