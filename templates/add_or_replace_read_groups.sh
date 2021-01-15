#!/bin/bash
# Add readgroups to the SAMs that have been aligned in the previous step
# Nextflow Inputs:
#   RUN_TAG
#   PROJECT_TAG
#   SAMPLE_TAG
#
#   PICARD
# Nextflow Outputs:
#   TODO
# Run:
#   TODO

# TODO
# Make run directory in /igo/stats/, e.g. /igo/stats/DIANA_0239_AHL5G5DSXY - All alignment and stat files will go here

#########################################
# Executes and logs command
# Arguments:
#   INPUT_CMD - string of command to run, e.g. "picard AddOrReplaceReadGroups ..."
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

BWA_SAMS=$(ls *.sam)    # Nextflow should pass all the SAMs in the input directory
RUN_TAG=$(parse_param !{RUN_PARAMS_FILE} RUN_TAG)
PROJECT_TAG=$(parse_param !{RUN_PARAMS_FILE} PROJECT_TAG)
SAMPLE_TAG=$(parse_param !{RUN_PARAMS_FILE} SAMPLE_TAG)

for BWA_SAM in $BWA_SAMS; do
  RGP_SAM=${BWA_SAM/BWA/RGP}    # "${SAM_SMP}___BWA.sam" -> "${SAM_SMP}___RGP.sam"
  RG_CMD="!{PICARD} AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true I=${BWA_SAM} O=${RGP_SAM} ID=${RUN_TAG} LB=${RUN_TAG} PU=${PROJECT_TAG} SM=${SAMPLE_TAG}  PL=illumina CN=IGO@MSKCC"
  run_cmd $RG_CMD
done

