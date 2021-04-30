#/bin/bash

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
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION} > /dev/null
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"

TYPE="i7"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME.csv ${EXPECTED_DIR}/SampleSheet_201105_ROSALIND_0002_FLOWCELLNAME_i7.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION[@]} > /dev/null
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"

TYPE="10X"
echo "Testing ${TYPE} split"
SOURCE_FILE=${SOURCE_DIR}/SampleSheet_210421_ROSALIND_0003_FLOWCELLNAME.csv
EXPECTED_FILES=( ${EXPECTED_DIR}/SampleSheet_210421_ROSALIND_0003_FLOWCELLNAME_10X.csv )
python3 ${LOCATION}/../create_multiple_sample_sheets.py --sample-sheet ${SOURCE_FILE} --processed-dir ${LOCATION} > /dev/null
ERRORS="${ERRORS}$(compare_files ${TYPE} ${SOURCE_FILE} ${LOCATION} ${EXPECTED_FILES[@]})\n"

OUTPUT=$(printf "$ERRORS" | grep -v "success" | sed "s/^/   /")
rm -rf ${LOCATION}/SampleSheet_*ROSALIND*_FLOWCELLNAME*.csv

if [[ ! -z "${OUTPUT}" ]]; then
  echo "ERRORS:"
  printf "$OUTPUT\n"
  exit 1
else
  echo "SUCCESS"
fi

