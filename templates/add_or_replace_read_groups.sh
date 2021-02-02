#!/bin/bash
# Add readgroups to the SAMs that have been aligned in the previous step
# Nextflow Inputs:
#   PICARD,     Picard Command
#   STATS_DIR,  Directory to write stats files to
#
#   RUN_PARAMS_FILE, space delimited k=v pairs of run parameters
#
# Nextflow Outputs:
#   RUN_PARAMS_FILE, Outputs sam file as input
#   SAM_CH, Outputs SAM w/ Readgroups (*.sam)

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard AddOrReplaceReadGroups ..."
#########################################
run_cmd () {
  INPUT_CMD=$@
  echo ${INPUT_CMD} >> !{CMD_FILE}
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

BWA_SAMS=$(ls *.sam)    # Nextflow should pass all the SAMs in the input directory
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)
PROJECT_TAG=$(parse_param !{RUN_PARAMS_FILE} PROJECT_TAG)
SAMPLE_TAG=$(parse_param !{RUN_PARAMS_FILE} SAMPLE_TAG)

for BWA_SAM in $BWA_SAMS; do
  RGP_SAM=${BWA_SAM/BWA/RGP}    # "${SAM_SMP}___BWA.sam" -> "${SAM_SMP}___RGP.sam"
  RG_CMD="!{PICARD} AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true I=${BWA_SAM} O=${RGP_SAM} ID=${RUN_TAG} LB=${RUN_TAG} PU=${PROJECT_TAG} SM=${SAMPLE_TAG}  PL=illumina CN=IGO@MSKCC"
  run_cmd $RG_CMD
done

