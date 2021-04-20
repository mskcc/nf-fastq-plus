#!/bin/bash

RECIPE=$1

if [[ -z ${RECIPE} ]]; then
  echo "Please provide recipe"
  exit 1
fi


case $RECIPE in
  HumanWholeGenome)
    FILE_SUFFIXES=( ___MD.txt ___AM.txt ___WGS.txt )
    ;;
  IDT_Exome_v2_FP_Viral_Probes)
    FILE_SUFFIXES=( ___MD.txt ___AM.txt )
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

SAMPLESHEET=${TEST_OUTPUT}/SampleSheets
mkdir -p ${SAMPLESHEET}
cat ${SAMPLESHEET_TEMPLATE} | sed "s/TARGET_RECIPE/${RECIPE}/g" > ${SAMPLESHEET}/SampleSheet_210419_ROSALIND_0001_AGTCTGAGTC.csv

STATS_DIR=${TEST_OUTPUT}/stats
STATSDONEDIR=${TEST_OUTPUT}/stats/DONE
mkdir -p ${STATSDONEDIR}

cd ${TEST_OUTPUT}
CMD="nextflow ${LOCATION}/../../samplesheet_stats_main.nf --dir ${DEMUXED_DIR} --ss ${SAMPLESHEET} --seq_dir ${SEQUENCER_DIR} --fq_dir ${FASTQ_DIR} --done_dir ${STATSDONEDIR}"
echo ${CMD}
eval ${CMD}
cd -

echo "TEST 1: Checking for bam"
FOUND_BAM=$(find ${STATS_DIR} -type f -name "*.bam")
if [ -z ${FOUND_BAM} ]; then
  printf "\tERROR: Pipeline didn't create BAM files\n"
else
  printf "\tFound BAM: ${FOUND_BAM}\n"
fi

echo "TEST 2: Checking for following output stat files - ${FILE_SUFFIXES[@]}"
for fs in "${FILE_SUFFIXES[@]}"; do
  FOUND_FILES=$(find ${STATSDONEDIR} -type f -name "*${fs}")
  if [ -z ${FOUND_FILES} ]; then
    printf "\tERROR: Pipeline didn't create ${fs} files\n"
  else
    printf "\tFound ${FOUND_FILES}\n"
  fi
done


