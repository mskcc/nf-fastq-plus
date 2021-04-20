#!/bin/bash

RECIPE=$1

if [[ -z ${RECIPE} ]]; then
  echo "Please provide recipe"
  exit 1
fi


case $RECIPE in
  HumanWholeGenome)
    FILE_SUFFIXES=( ___MD.txt ___AM.txt ___gc_bias_metrics.txt ___WGS.txt )
    ;;
  IDT_Exome_v2_FP_Viral_Probes)
    FILE_SUFFIXES=( ___AM.txt ___gc_bias_metrics.txt ___HS.txt )
    ;;
  *)
    echo "Could not find a pattern matching recipe: ${RECIPE}"
    exit 1
    ;;
esac

LOCATION=$(realpath $(dirname "$0"))
TEST_OUTPUT=${LOCATION}/test_output___${RECIPE}

DEMUXED_DIR=${LOCATION}/../data/FASTQ/ROSALIND_0001_AGTCTGAGTC
SAMPLESHEET_TEMPLATE=${LOCATION}/../data/SampleSheets/SampleSheet_210419_ROSALIND_0001_AGTCTGAGTC.csv

SAMPLESHEET_DIR=${TEST_OUTPUT}/SampleSheets
mkdir -p ${SAMPLESHEET_DIR}
SAMPLESHEET=${SAMPLESHEET_DIR}/SampleSheet_210419_ROSALIND_0001_AGTCTGAGTC.csv
cat ${SAMPLESHEET_TEMPLATE} | sed "s/TARGET_RECIPE/${RECIPE}/g" > ${SAMPLESHEET}

STATS_DIR=${TEST_OUTPUT}/stats
STATSDONEDIR=${TEST_OUTPUT}/stats/DONE
mkdir -p ${STATSDONEDIR}

cd ${TEST_OUTPUT}
CMD="nextflow ${LOCATION}/../../samplesheet_stats_main.nf --dir ${DEMUXED_DIR} --ss ${SAMPLESHEET} --stats_dir ${STATS_DIR} --done_dir ${STATSDONEDIR}"
echo ${CMD}
eval ${CMD}
cd -

ERRORS=""
echo "TEST 1: Checking for bam"
FOUND_BAM=$(find ${STATS_DIR} -type f -name "*.bam")
if [ -z ${FOUND_BAM} ]; then
  ERROR="\tERROR: Pipeline didn't create BAM files\n"
  ERRORS="${ERRORS}${ERROR}"
  printf "$ERROR"
else
  printf "\tFound BAM: ${FOUND_BAM}\n"
fi

echo "TEST 2: Checking for following output stat files - ${FILE_SUFFIXES[@]}"
for fs in "${FILE_SUFFIXES[@]}"; do
  FOUND_FILES=$(find ${STATSDONEDIR} -type f -name "*${fs}")
  if [ -z ${FOUND_FILES} ]; then
    ERROR="\tERROR: Pipeline didn't create ${fs} files\n"
    printf "$ERROR"
    ERRORS="${ERRORS}${ERROR}"
  else
    printf "\tFound ${FOUND_FILES}\n"
  fi
done

if [ -z "${ERRORS}" ]; then
  echo "All tests successful - removing test_output directories"
  rm -rf ${LOCATION}/test_output___*
else
  printf "ERRORS were found - ${ERRORS}"
fi


