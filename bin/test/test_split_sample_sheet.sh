#!/bin/bash
LOCATION=$(dirname "$0")

EXPECTED_DIR=${LOCATION}/data/split_sampleSheet/split
SOURCE_DIR=${LOCATION}/data/split_sampleSheet/original

function compare_files {
  TYPE=$1
  SOURCE=$2
  TARGET_DIR=$3
  EXPECTED=${@:4}

  for f in ${EXPECTED}; do
    fname=${LOCATION}/$(basename $f)
    # Test that file was written
    if [ ! -f ${fname} ]; then
      echo "${TYPE}___${fname}___Not_written"
      exit 1
    fi
    diffs=$(diff $fname ${f})
    if [[ ! -z $diffs ]]; then
      echo "${TYPE}___${fname}___Different"
      exit 1
    fi
  done

  # Test correct number of files written
  base_file=$(basename ${SOURCE} | cut -d'.' -f1)                       # /path/to/base_file.csv -> base_file
  num_expected=$(echo ${EXPECTED} | tr ' ' '\n' | wc -l | tr -d " ")
  actual_files=$(ls ${TARGET_DIR} | grep ${base_file})
  num_actual=$(echo ${actual_files} | tr ' ' '\n' | wc -l | tr -d " ")
  if [[ "${num_expected}" != "${num_actual}" ]]; then
    printf "Incorrect number - Expected ${num_expected}, but found ${num_actual}.\n${actual_files}"
    exit 1
  fi

  echo "success"
}

ERRORS=""
TYPE="DLP_WGS"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME.csv ${EXPECTED_DIR}/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME_DLP.csv ${EXPECTED_DIR}/SampleSheet_210422_ROSALIND_0001_FLOWCELLNAME_WGS.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="i7"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv ${EXPECTED_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME_i7.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION[@]}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="10X"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210421_ROSALIND_0003_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0003_FLOWCELLNAME_10X.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="10X_Multiome"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210421_ROSALIND_0007_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0007_FLOWCELLNAME_10X_Multiome.csv ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0007_FLOWCELLNAME_10X.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="6nt_dual"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210421_ROSALIND_0004_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0004_FLOWCELLNAME.csv ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0004_FLOWCELLNAME_6nt.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="6nt_single"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210504_ROSALIND_0006_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210504_ROSALIND_0006_FLOWCELLNAME.csv ${EXPECTED_DIR}/SampleSheet_210504_ROSALIND_0006_FLOWCELLNAME_6nt.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="MB_DNA_PRT"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210716_ROSALIND_0008_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210716_ROSALIND_0008_FLOWCELLNAME_MB_DNA.csv ${EXPECTED_DIR}/SampleSheet_210716_ROSALIND_0008_FLOWCELLNAME_MB_PTN.csv SampleSheet_210716_ROSALIND_0008_FLOWCELLNAME_MB_WGS.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION}
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

TYPE="NO"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210503_ROSALIND_0005_FLOWCELLNAME.csv
EXPECTED_FILES=( )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION} > /dev/null
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"
written_samplesheets=$(find . -maxdepth 1 -type f -name "SampleSheet_*.csv")
if [[ ! -z "${written_samplesheets}" ]]; then
  ERRORS="${ERRORS} Samplesheets written when no split should have happened: $(echo ${written_samplesheets} | tr ' ' '_')"
fi
OUTPUT=$(printf "$ERRORS" | grep -v "success" | sed "s/^/   /")
if [[ ! -z "${OUTPUT}" ]]; then
  echo "ERRORS:"
  printf "$OUTPUT\n"
  exit 1
else
  echo "SUCCESS"
fi

