#!/bin/bash

RECIPE=$1

if [[ -z ${RECIPE} ]]; then
  RECIPE="ALL"
  echo "No Recipe provided, running RECIPE=$RECIPE"
fi

cp_samplesheet () {
  RECIPE=$1
  SOURCE_SAMPLESHEET=$2
  TARGET_SAMPLESHEET=$3
  # Copy over all the headers
  sed '/Lane,/q' $SOURCE_SAMPLESHEET > $TARGET_SAMPLESHEET
  
  # Copy over only the rows w/ the Recipe
  cat $SOURCE_SAMPLESHEET | grep $RECIPE >> $TARGET_SAMPLESHEET
}

LOCATION=$(realpath $(dirname "$0"))
TEST_OUTPUT=${LOCATION}/test_output___${RECIPE}

DEMUXED_DIR=${LOCATION}/../data/FASTQ/ROSALIND_0001_AGTCTGAGTC
SAMPLESHEET_TEMPLATE=${LOCATION}/../data/SampleSheets/SampleSheet_210419_ROSALIND_0001_AGTCTGAGTC.csv

SAMPLESHEET_DIR=${TEST_OUTPUT}/SampleSheets
mkdir -p ${SAMPLESHEET_DIR}
SAMPLESHEET=${SAMPLESHEET_DIR}/SampleSheet_210419_ROSALIND_0001_AGTCTGAGTC.csv

# TODO - find better way of limiting what gets tested
case $RECIPE in
  HWG)
    RECIPE=HumanWholeGenome
    echo "RECIPE=${RECIPE}"
    cp_samplesheet $RECIPE $SAMPLESHEET_TEMPLATE $SAMPLESHEET
    FILE_SUFFIXES=( ___MD.txt ___AM.txt ___gc_bias_metrics.txt ___WGS.txt )
    ;;
  IDT)
    RECIPE=IDT_Exome_v2_FP_Viral_Probes
    echo "RECIPE=${RECIPE}"
    cp_samplesheet $RECIPE $SAMPLESHEET_TEMPLATE $SAMPLESHEET
    FILE_SUFFIXES=( ___AM.txt ___gc_bias_metrics.txt ___HS.txt )
    ;;
  RNA)
    RECIPE=RNASeq_PolyA
    echo "RECIPE=${RECIPE}"
    cp_samplesheet $RECIPE $SAMPLESHEET_TEMPLATE $SAMPLESHEET
    FILE_SUFFIXES=( ___AM.txt ___gc_bias_metrics.txt ) # ___RNA.txt ) # Should check for RNA, but need to add valid files
    ;;
  ALL)
    cp $SAMPLESHEET_TEMPLATE $SAMPLESHEET
    FILE_SUFFIXES=( ___MD.txt ___AM.txt ___gc_bias_metrics.txt ___WGS.txt ___HS.txt )
    ;;
  *)
    echo "ERROR: RECIPE=${RECIPE} is not recognized"
    echo "Usage: ./samplesheet_stats_main_test.sh [ IDT | HWG | RNA | ALL ]"
    exit 1
esac

STATS_DIR=${TEST_OUTPUT}/stats
STATSDONEDIR=${TEST_OUTPUT}/stats/DONE
mkdir -p ${STATSDONEDIR}

cd ${TEST_OUTPUT}
touch ${RECIPE}.out
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
  echo "All tests successful - removing ${TEST_OUTPUT}"
  rm -rf ${TEST_OUTPUT}
else
  cat ${OUT_FILE}
  printf "ERRORS were found - \n${ERRORS}"
  exit 1
fi


