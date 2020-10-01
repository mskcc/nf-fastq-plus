#!/bin/bash
#
# Performs picard AddOrReplaceReadGroups

# TODO - to run this script separately, there will need to be logic to re-assign the SAM INPUT 

INPUT_SAM=!{SAM_CH}
OUTPUT="${INPUT_SAM/$OUT_BWA/$OUT_RG}"

printf "OUTPUT: ${OUTPUT}\nINPUT: ${INPUT_SAM}\nOUT_BWA: ${OUT_BWA}\nOUT_RG: ${OUT_RG}\n"


CMD="picard AddOrReplaceReadGroups SO=coordinate CREATE_INDEX=true I=${INPUT_SAM} O=${OUTPUT} ID=${RUN_TAG} LB=${RUN_TAG} PL=illumina PU=${PROJECT_TAG} SM=${SAMPLE_TAG} CN=IGO@MSKCC"
echo $CMD

# TODO - remove
exit 1
